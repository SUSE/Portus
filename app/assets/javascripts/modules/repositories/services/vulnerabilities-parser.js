const AVAILABLE_BACKENDS = ['clair', 'zypper', 'dummy'];

export const parse = function (vulnerabilities) {
  const severities = {
    High: 0,
    Normal: 0,
    Low: 0,
  };
  let total = 0;

  if (vulnerabilities) {
    AVAILABLE_BACKENDS.forEach((backend) => {
      if (!vulnerabilities[backend]) {
        return;
      }

      this.tag[0].vulnerabilities[backend].forEach((vul) => {
        severities[vul.Severity] += 1;
        total += 1;
      });
    });
  }

  return {
    total,
    severities,
  };
};

export default {
  parse,
};
