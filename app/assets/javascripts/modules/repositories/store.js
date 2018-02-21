export default class RepositoriesStore {
  constructor() {
    this.state = {
      isDeleting: false,
      repository: {},
    };

    this.state.selectedTags = [];
  }
}
