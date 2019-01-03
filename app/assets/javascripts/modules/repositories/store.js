export default class RepositoriesStore {
  constructor() {
    this.state = {
      commentFormVisible: false,
      descriptionFormVisible: false,
      isDeleting: false,
      isLoading: true,
      notLoaded: false,
      selectedTags: [],
      currentTab: 'tags',
    };
  }
}
