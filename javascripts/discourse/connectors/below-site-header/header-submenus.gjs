import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { and, eq } from "discourse/truth-helpers";
import icon from "discourse/ui-kit/helpers/d-icon";

const getClassName = (text) =>
  (text || "")
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]/g, "-");

export default class HeaderSubmenus extends Component {
  @service router;

  @tracked activeItem = null;

  get shouldDisplay() {
    const route = this.router.currentRouteName;

    if (!route) {
      return false;
    }

    if (route.startsWith("admin")) {
      return false;
    }

    if (
      route.includes("login") ||
      route.includes("signup") ||
      route.includes("password-reset")
    ) {
      return false;
    }

    if (route.startsWith("user.")) {
      return false;
    }

    return true;
  }

  get menuItems() {
    const items = settings.navigation_menu;

    if (!items || !items.length) {
      return null;
    }

    return items.map((item, index) => ({
      id: `${item.text}-${index}`,
      text: item.text,
      className: getClassName(item.text),
      childItems: (item.children || [])
        .filter((child) => child.text && child.link)
        .map((child) => ({
          text: child.text,
          href: child.link,
          className: getClassName(child.text),
        })),
    }));
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
    {{#if (and this.shouldDisplay this.menuItems)}}
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
