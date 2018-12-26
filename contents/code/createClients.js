
// This creates our new thumbnails.
function createAllClientThumbnails(parentContainer, dashboard, columns, height, width, isLarge) {
  var c; // client
  for (c = 0; c < workspace.clientList().length; c++) {
    if (true) {
      // Don't make ones for docks.  Or desktops.
      console.log('WHAT SORT ARE WE?');
      console.log(workspace.clientList()[c].windowType);
      if (!workspace.clientList()[c].dock && workspace.clientList()[c].normalWindow) {
      //if (!workspace.clientList()[c].dock) {
        var clientThumbnail = Qt.createComponent('../ui/ClientThumbnail.qml')
        if( clientThumbnail.status == Component.Error )
            console.debug("Error:"+ clientThumbnail.errorString() );
        console.log('Attempting creation');
        clientThumbnail.createObject(parentContainer,
                                    // Custom ID for destruction later.
                                    {id: 'clientId' + c,
                                    //'background': model.get(0).background,
                                    'clientObject': workspace.clientList()[c],
                                    'originalWidth':  workspace.clientList()[c].width, //parentContainer.width, //100, //workspace.clientList()[c].width / columns,
                                    'originalHeight': workspace.clientList()[c].height, //parentContainer.height, //workspace.clientList()[c].height / columns,
                                    'scale': (height / width) / (dashboard.height/dashboard.width),
                                    'clientId': workspace.clientList()[c].windowId,
                                    // We'll use this to determine where to switch from.
                                    'currentDesktop': workspace.clientList()[c].desktop,
                                    'newDesktop': workspace.clientList()[c].desktop,
                                    'isLarge': isLarge,
                                    'newActivity': workspace.clientList()[c].activities,
                                    // We don't want to actually SHOW these, yet.
                                    // We'll just distribute them accordingly.
                                    'visible': true,
                                    'x': workspace.clientList()[c].x, 'y': workspace.clientList()[c].y,
                                    'clientRealX': workspace.clientList()[c].x,
                                    // Account for the fucking dock, if any.
                                    'clientRealY': workspace.clientList()[c].y,
                                    'clientRealWidth': workspace.clientList()[c].width,
                                    'clientRealHeight': workspace.clientList()[c].height,
                                    'height': workspace.clientList()[c].height, //parentContainer.height, //height / columns,
                                    'width': workspace.clientList()[c].height});//parentContainer.width}); //width / columns});
      console.log('Client created!');
      }
    }
  }
}
// Here, we just create a new thumbnail as necessary.  Later, we'll reparent it.
function createNewClientThumbnails(parentContainer, dashboard, columns, height, width, isLarge, c) {
  //if (!c.dock) {
  console.log('WHAT SORT ARE WE?');
  console.log(c.windowType, c.windowRole, c.desktopWindow, c.normalWindow);
  if (!c.dock && c.normalWindow) {
  //if (!c.dock) {
    var clientThumbnail = Qt.createComponent('../ui/ClientThumbnail.qml')
    if( clientThumbnail.status == Component.Error )
        console.debug("Error:"+ clientThumbnail.errorString() );
    clientThumbnail.createObject(parentContainer,
                                // Custom ID for destruction later.
                                {id: 'clientId' + c,
                                //'background': model.get(0).background,
                                'clientObject': c,
                                'originalWidth':  c.width, //parentContainer.width, //100, //workspace.clientList()[c].width / columns,
                                'originalHeight': c.height, //parentContainer.height, //workspace.clientList()[c].height / columns,
                                'scale': (height / width) / (dashboard.height/dashboard.width),
                                'clientId': c.windowId,
                                'currentDesktop': c.desktop,
                                'newDesktop': c.desktop,
                                'isLarge': isLarge,
                                'newActivity': c.activities,
                                // We don't want to actually SHOW these, yet.
                                // We'll just distribute them accordingly.
                                'visible': false,
                                'x': c.x, 'y': c.y,
                                'clientRealX': c.x,
                                // Account for the fucking dock, if any.
                                'clientRealY': c.y,
                                'clientRealWidth': c.width,
                                'clientRealHeight': c.height,
                                'height': c.height,//parentContainer.height, //height / columns,
                                'width': c.width});//parentContainer.width}); //width / columns});
  }
}
