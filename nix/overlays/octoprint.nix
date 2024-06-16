final: prev: {
  octoprint = prev.octoprint.override {
    packageOverrides = octoFinal: octoPrev: let
      inherit (final) fetchFromGitHub lib;
      buildPlugin = args:
        octoPrev.buildPythonPackage (args
          // {
            pname = "octoprint-plugin-${args.pname}";
            inherit (args) version;
            propagatedBuildInputs = (args.propagatedBuildInputs or []) ++ [octoPrev.octoprint];
            # none of the following have tests
            doCheck = false;
          });
    in {
      inherit buildPlugin;

      m73-eta-override = buildPlugin rec {
        pname = "m73-eta-override";
        version = "1.0.4";

        src = fetchFromGitHub {
          owner = "gdombiak";
          repo = "OctoPrint-M73ETAOverride";
          rev = version;
          sha256 = "sha256-sp9Ux4JfP0oM+PkxCz2H8n6LRjoUE1xsiAfMe8EFLa8=";
        };

        meta = with lib; {
          description = "Plugin that overrides OctoPrint ETA to values from last M73 gcode sent to the printer. ";
          homepage = "https://github.com/gdombiak/OctoPrint-M73ETAOverride";
          license = licenses.agpl3Only;
          # maintainers = with maintainers; [stunkymonkey];
        };
      };

      octolapse = buildPlugin rec {
        pname = "octolapse";
        version = "0.4.5";

        src = fetchFromGitHub {
          owner = "FormerLurker";
          repo = "Octolapse";
          rev = "v${version}";
          sha256 = "sha256-2lxE+Nzwcf4hJYiQ+0RmUzU70ZDu2qQS7W8GU7JYlvQ=";
        };

        # Test fails due to code executed on import, see #136513
        #pythonImportsCheck = [ "octoprint_octolapse" ];

        propagatedBuildInputs = with octoPrev; [awesome-slugify setuptools pillow sarge six pillow psutil file-read-backwards];

        meta = with lib; {
          description = "Stabilized timelapses for Octoprint";
          homepage = "https://github.com/FormerLurker/OctoLapse";
          license = licenses.agpl3Plus;
          maintainers = with maintainers; [illustris j0hax];
        };
      };

      obico = buildPlugin rec {
        pname = "obico";
        version = "2.5.0";

        src = fetchFromGitHub {
          owner = "TheSpaghettiDetective";
          repo = "OctoPrint-Obico";
          rev = version;
          sha256 = "sha256-cAUXe/lRTqYuWnrRiNDuDjcayL5yV9/PtTd9oeSC8KA=";
        };

        meta = with lib; {
          description = "Obico plugin for OctoPrint";
          homepage = "https://github.com/TheSpaghettiDetective/OctoPrint-Obico";
          license = licenses.agpl3Only;
          # maintainers = with maintainers; [stunkymonkey];
        };
      };

      plotly-temp-graph = buildPlugin rec {
        pname = "plotly-temp-graph";
        version = "0.1.7";

        src = fetchFromGitHub {
          owner = "jneilliii";
          repo = "OctoPrint-PlotlyTempGraph";
          rev = version;
          sha256 = "sha256-sFpCbnq1Jq49AQjUI5ko3TQy2td7GDhv9rLFW/kHluc=";
        };

        meta = with lib; {
          description = "This plugin replaces the default temperature tab of OctoPrint with a plotly graph that incorporates other data supplied by the return of plugin's octoprint-comm-protocol-temperatures-received callbacks.";
          homepage = "https://github.com/jneilliii/OctoPrint-PlotlyTempGraph";
          license = licenses.agpl3Only;
          # maintainers = with maintainers; [stunkymonkey];
        };
      };

      pretty-gcode-viewer = buildPlugin rec {
        pname = "pretty-gcode-viewer";
        version = "1.2.4";

        src = fetchFromGitHub {
          owner = "Kragrathea";
          repo = "OctoPrint-PrettyGCode";
          rev = "v${version}";
          sha256 = "sha256-q/B2oEy+D6L66HqmMkvKfboN+z3jhTQZqt86WVhC2vQ=";
        };

        meta = with lib; {
          description = "This plugin adds a 3D GCode visualizer tab in Octoprint.";
          homepage = "https://github.com/Kragrathea/OctoPrint-PrettyGCode";
          license = licenses.agpl3Only;
          # maintainers = with maintainers; [stunkymonkey];
        };
      };

      spool-manager = buildPlugin rec {
        pname = "spool-manager";
        version = "1.7.3";

        src = fetchFromGitHub {
          owner = "dojohnso";
          repo = "OctoPrint-SpoolManager";
          rev = version;
          sha256 = "sha256-KUuDHs6R3xK6XjjmjqKWJWxAOHMq1NJKCByUyVvwIb0=";
        };

        meta = with lib; {
          description = "Plugin for managing Spools.";
          homepage = "https://github.com/dojohnso/OctoPrint-SpoolManager";
          license = licenses.agpl3Only;
          # maintainers = with maintainers; [stunkymonkey];
        };
      };
    };
  };
}
