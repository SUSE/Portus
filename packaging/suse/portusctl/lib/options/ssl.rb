module Portusctl
  module Options
    module SSL
      def self.included(thor)
        thor.class_eval do
          option "ssl-gen-self-signed-certs",
                 desc:    "Generate self-signed certificates",
                 type:    :boolean,
                 default: false
          option "ssl-certs-dir",
                 desc:      "Location of own certificates",
                 default:   "",
                 long_desc: <<-LONGDESC
Looks for the following required certificate files in the specified folder:
   * `<custom dir>/<hostname>-ca.key`: the certificate key
   * `<custom dir>/<hostname>-ca.crt`: the certificate file
  LONGDESC
          option "ssl-organization",
                 desc:    "SSL certificate: organization",
                 default: "SUSE Linux GmbH" # gensslcert -o
          option "ssl-organization-unit",
                 desc:    "SSL certificate: organizational unit",
                 default: "SUSE Portus example" # gensslcert -u
          option "ssl-email",
                 desc:    "SSL certificate: email address of webmaster",
                 default: "kontact-de@novell.com" # gensslcert -e
          option "ssl-country",
                 desc:    "SSL certificate: country (two letters)",
                 default: "DE" # gensslcert -c
          option "ssl-city",
                 desc:    "SSL certificate: city",
                 default: "Nuernberg" # gensslcert -l
          option "ssl-state",
                 desc:    "SSL certificate: state",
                 default: "Bayern" # gensslcert -s
        end
      end
    end
  end
end
