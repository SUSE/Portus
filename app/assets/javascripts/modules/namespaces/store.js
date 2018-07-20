class RepositoriesStore {
  constructor() {
    this.state = {
      newFormVisible: false,
      editFormVisible: false,
      isDeleting: false,
      isLoading: false,
      notLoaded: false,
      onGoingVisibilityRequest: false,
    };
  }
}

export default new RepositoriesStore();
