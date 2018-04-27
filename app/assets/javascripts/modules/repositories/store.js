export default class RepositoriesStore {
  constructor() {
    this.state = {
      commentFormVisible: false,
      isDeleting: false,
      repository: {},
    };

    this.state.selectedTags = [];
  }
}
