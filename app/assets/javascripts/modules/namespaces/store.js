class RepositoriesStore {
  constructor() {
    this.state = {
      newFormVisible: false,
      editFormVisible: false,
      isLoading: false,
      notLoaded: false,
      onGoingVisibilityRequest: false,
    };
  }
}

export default new RepositoriesStore();
