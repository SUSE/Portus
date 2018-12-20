const countBySeverities = function (vulnerabilities) {
  const severities = {
    Negligible: 0,
    Unknown: 0,
    Low: 0,
    Medium: 0,
    High: 0,
    Critical: 0,
    Defcon1: 0,
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
