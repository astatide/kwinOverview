
// This creates our new thumbnails.
function createAllClientThumbnails(parentContainer, dashboard, columns, height, width, isLarge) {
  var c; // client
  for (c = 0; c < workspace.clientList().length; c++) {
    if (true) {
      // Don't make ones for docks.
      if (!workspace.clientList()[c].dock) {
        var clientThumbnail = Qt.createComponent('../ui/ClientThumbnail.qml')
        if( clientThumbnail.status == Component.Error )
            console.debug("Error:"+ clientThumbnail.errorString() );
        console.log('Attempting creation');
        clientThumbnail.createObject(parentContainer,
                                    // Custom ID for destruction later.
                                    {id: 'clientId' + c,
                                    //'background': model.get(0).background,
                                    'clientObject': workspace.clientList()[c],
                                    'originalWidth': width / columns,
                                    'originalHeight': height / columns,
                                    'scale': (height / width) / (dashboard.screenHeight/dashboard.screenWidth),
                                    'clientId': workspace.clientList()[c].windowId,
                                    // We'll use this to determine where to switch from.
                                    'currentDesktop': workspace.clientList()[c].desktop,
                                    'isLarge': isLarge,
                                    // We don't want to actually SHOW these, yet.
                                    // We'll just distribute them accordingly.
                                    'visible': false,
                                    'x': 0, 'y': 0,
                                    'clientRealX': workspace.clientList()[c].x,
                                    // Account for the fucking dock, if any.
                                    'clientRealY': workspace.clientList()[c].y,
                                    'clientRealWidth': workspace.clientList()[c].width,
                                    'clientRealHeight': workspace.clientList()[c].height,
                                    'height': height / columns,
                                    'width': width / columns});
      console.log('Client created!');
      }
    }
  }
}
// Here, we just create a new thumbnail as necessary.  Later, we'll reparent it.
function createNewClientThumbnails(parentContainer, dashboard, columns, height, width, isLarge, c) {
  var clientThumbnail = Qt.createComponent('../ui/ClientThumbnail.qml')
  if( clientThumbnail.status == Component.Error )
      console.debug("Error:"+ clientThumbnail.errorString() );
  clientThumbnail.createObject(parentContainer,
                              // Custom ID for destruction later.
                              {id: 'clientId' + c,
                              //'background': model.get(0).background,
                              'clientObject': c,
                              'originalWidth': width / columns,
                              'originalHeight': height / columns,
                              'scale': (height / width) / (dashboard.screenHeight/dashboard.screenWidth),
                              'clientId': c.windowId,
                              'currentDesktop': c.desktop,
                              'isLarge': isLarge,
                              // We don't want to actually SHOW these, yet.
                              // We'll just distribute them accordingly.
                              'visible': false,
                              'x': 0, 'y': 0,
                              'clientRealX': c.x,
                              // Account for the fucking dock, if any.
                              'clientRealY': c.y,
                              'clientRealWidth': c.width,
                              'clientRealHeight': c.height,
                              'height': height / columns,
                              'width': width / columns});
}
