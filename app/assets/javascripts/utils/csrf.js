const token = () => {
  const tokenEl = document.querySelector('meta[name=csrf-token]');

  if (tokenEl !== null) {
    return tokenEl.getAttribute('content');
  }

  return null;
};

export default {
  token,
};
