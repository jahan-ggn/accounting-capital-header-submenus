import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { eq } from "discourse/truth-helpers";

const getClassName = (text) => text.toLowerCase().replace(/\s/g, "-");

export default class HeaderSubmenus extends Component {
  @service site;

  @tracked activeItem = null;

  get menuItems() {
    const selectedIds = (settings.navigation_categories || "")
      .split("|")
      .map((id) => parseInt(id.trim(), 10))
      .filter(Boolean);

    if (!selectedIds.length) {
      return null;
    }

    return selectedIds
      .map((id) => {
        const category = this.site.categories.find((c) => c.id === id);
        if (!category) {
          return null;
        }

        return {
          id: category.id,
          text: category.name,
          className: getClassName(category.name),
          childItems: this.site.categories
            .filter((c) => c.parent_category_id === category.id)
            .map((sub) => ({
              text: sub.name,
              className: getClassName(sub.name),
              href: sub.url,
            })),
        };
      })
      .filter(Boolean);
  }

  @action
  onMouseEnter(itemId) {
    this.activeItem = itemId;
  }

  @action
  onMouseLeave() {
    this.activeItem = null;
  }

  <template>
    {{#if this.menuItems}}
      <div class="header-submenus">
        <div id="top-menu" class="top-menu">
          <div class="menu-content wrap">
            <div class="menu-placeholder">
              <div class="menu-item-container">
                <div class="menu-items">
                  {{#each this.menuItems as |item|}}
                    <span
                      class="menu-item {{item.className}}"
                      {{on "mouseenter" (fn this.onMouseEnter item.id)}}
                      {{on "mouseleave" this.onMouseLeave}}
                    >
                      {{item.text}}
                      {{icon "angle-right"}}

                      {{#if (eq this.activeItem item.id)}}
                        {{#if item.childItems.length}}
                          <div class="d-header-dropdown">
                            <ul class="d-dropdown-menu">
                              {{#each item.childItems as |child|}}
                                <li class="submenu-item {{child.className}}">
                                  <a class="submenu-link" href={{child.href}}>
                                    {{child.text}}
                                  </a>
                                </li>
                              {{/each}}
                            </ul>
                          </div>
                        {{/if}}
                      {{/if}}
                    </span>
                  {{/each}}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
