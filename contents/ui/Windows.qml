import QtQuick 2.0
//import org.kde.kwin 2.0 as KWin
//import org.kde.kwin 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma


Item {

  id: clients
  // Here, we're passing through our clients to anything that calls us.
  property int nClients: { workspace.clientList().length }
  property var clientList: { workspace.clientList() }
  property int nDesktops: { workspace.desktops }
  //property var desktopList: { workspace.desktopList() }
  //property int allClientList: { workspace.unmanagedList() }

  Component.onCompleted: {
    // Oh fuck, I think this actually works.  What an odd import statement.
    //var clients = workspace.clientList();
    // THIS ACTUALLY WORKS.
    //n_clients = clients.length;
    //test.nClients = 6;
    console.log('STarting');
  }

}
