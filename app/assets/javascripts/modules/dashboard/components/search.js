import BaseComponent from '~/base/component';

const SEARCH_FIELD = '#search';
const CTRL = 17;
const SPACE = 32;

// SearchComponent handles the state and the dynamic behavior of the
// search input.
class SearchComponent extends BaseComponent {
  elements() {
    // Instance variables.
    this.keys = [
      { key: CTRL, pressed: false },
      { key: SPACE, pressed: false },
    ];
    this.keypressed = void 0;

    // UI elements.
    this.$search = this.$el.find(SEARCH_FIELD);
  }

  events() {
    this.$el.on('keydown', e => this.onKey(e, true));
    this.$el.on('keyup', e => this.onKey(e, false));
  }

  // onKey is a callback that should be executed on key events. The first
  // parameter is the event object, and `down` is a boolean specifying whether
  // this is a "keydown" event or not.
  onKey(e, down) {
    if (e.keyCode === CTRL || e.keyCode === SPACE) {
      // If we are on a key down event and ctrl is currently pressed, the
      // spacebar default action wont be triggered
      if (down && this.keys[0].v) {
        e.preventDefault();
      }

      this.keypressed = e.keyCode;
      this.searchKey(this.keypressed, down);
    }
  }

  // openSearch scrolls to the top if needed and focuses the search input.
  openSearch() {
    if ($(window).scrollTop() > 0) {
      $('html,body').unbind().animate({ scrollTop: 0 }, 500);
    }
    this.$search.val('').focus();
  }

  // activateSearch calls openSearch if both keys are pressed at the same time.
  activateSearch() {
    var performSearch = 0;

    $.each(this.keys, (i) => {
      if (this.keys[i].pressed) {
        performSearch++;
      }
      if (performSearch === 2) {
        this.openSearch();
      }
    });
  }

  // searchKey sets the given key as pressed/unpressed if it's one of the two
  // keys.
  searchKey(key, pressed) {
    $.each(this.keys, (i) => {
      if (this.keys[i].key === key) {
        this.keys[i].pressed = pressed;
      }
    });
    this.activateSearch();
  }
}

export default SearchComponent;
