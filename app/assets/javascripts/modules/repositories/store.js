export default class RepositoriesStore {
  constructor() {
    this.state = {
      commentFormVisible: false,
      isDeleting: false,
      isLoading: true,
      notLoaded: false,
      selectedTags: [],
    };
  }
}
