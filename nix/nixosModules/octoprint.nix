{
  services.octoprint = {
    enable = true;
    plugins = plugins:
      with plugins; [
        bedlevelvisualizer
        dashboard
        displaylayerprogress
        gcodeeditor
        m73-eta-override
        obico
        octolapse
        plotly-temp-graph
        pretty-gcode-viewer
        spool-manager
        telegram
        themeify
      ];
  };
}
