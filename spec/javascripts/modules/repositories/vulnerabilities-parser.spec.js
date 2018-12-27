import VulnerabilitiesParser from '~/modules/repositories/services/vulnerabilities-parser';

describe('VulnerabilitiesParser', () => {
  describe('#countBySeverities', () => {
    const emptyVulnerabilities = [];
    const vulnerabilities = [
      { severity: 'Critical' },
      { severity: 'High' },
      { severity: 'High' },
      { severity: 'Medium' },
      { severity: 'Low' },
      { severity: 'Low' },
      { severity: 'Negligible' },
    ];
    const severitiesNames = ['Defcon1', 'Critical', 'High', 'Medium', 'Low', 'Unknown', 'Negligible'];

    it('returns object with severities categories', () => {
      const severities = VulnerabilitiesParser.countBySeverities(vulnerabilities);

      expect(Object.keys(severities)).toEqual(severitiesNames);
    });

    it('returns object with severities zero', () => {
      const severities = VulnerabilitiesParser.countBySeverities(emptyVulnerabilities);

      severitiesNames.forEach((s) => {
        expect(severities[s]).toBe(0);
      });
    });

    it('counts vulnerabilities by category', () => {
      const severities = VulnerabilitiesParser.countBySeverities(vulnerabilities);

      expect(severities.Critical).toBe(1);
      expect(severities.High).toBe(2);
      expect(severities.Medium).toBe(1);
      expect(severities.Low).toBe(2);
      expect(severities.Unknown).toBe(0);
      expect(severities.Negligible).toBe(1);
    });
  });
});
