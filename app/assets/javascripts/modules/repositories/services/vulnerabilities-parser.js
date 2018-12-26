const countBySeverities = function (vulnerabilities) {
  const severities = {
    Defcon1: 0,
    Critical: 0,
    High: 0,
    Medium: 0,
    Low: 0,
    Unknown: 0,
    Negligible: 0,
  };

  if (vulnerabilities) {
    vulnerabilities.forEach((vul) => {
      severities[vul.severity] += 1;
    });
  }

  return severities;
};

export default {
  countBySeverities,
};
