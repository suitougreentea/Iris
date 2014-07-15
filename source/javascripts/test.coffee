#= require "zebra.js"

#zebra()["zebra.json"] = "javascripts/zebra.json"
#zebra()["zebra.png"] = "javascripts/zebra.png"
zebra.ready ->
  console.log "Zebra ready"
  eval(zebra.Import("ui", "layout"))
  root = (new zCanvas("screen")).root
  root.properties {
    layout: new BorderLayout(8, 8),
    border: new Border(),
    padding: 8,
    kids: {
      CENTER: new TextField("", true)
      BOTTOM: new Button("").properties({
        canHaveFocus: false
      })
    }
  }
  console.log "hey"
