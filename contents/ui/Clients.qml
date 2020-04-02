import QtQuick 2.7
import QtQuick.Layouts 1.12
import org.kde.kwin 2.0 as KWinLib
//import org.kde.kwin 2.0;
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma

// Trying to get the image provider to work.
import org.kde.activities.settings 0.1
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents

import org.kde.plasma.activityswitcher 1.0 as ActivitySwitcher

import org.kde.activities 0.1 as Activities

Item {
  id: clientContainer
  property int desktop: 0
  property bool isMain: false
  property bool isLarge: false
  x: 0
  y: 0
  scale: 1
  height: parent.height
  width: parent.width

  Grid {
    id: clientGridLayout
    rows: _returnMatrixSize()
    columns: _returnMatrixSize()
    height: parent.height
    width: parent.width
    property int onDesktop: _onDesktop()
    property int forceReset: 0
    //rowSpacing: 20 * (clientContainer.height/dashboard.screenHeight)
    //scale: 1
    //flow: GridLayout.TopToBottom

    function _onDesktop() {
      var cc = 0;
      //for (var i = 0; i < workspace.clients.length; i++) {
      //  if (workspace.clients[i].desktop-1 == clientContainer.desktop) {
      //    cc++;
      //  }
      //}
      for (var i = 0; i < clientGridLayout.children.length; i++) {
        //console.log('What is our child?', clientGridLayout.children[i]);
        //console.log('What is our client?', clientGridLayout.children[i].client);
        //console.log('What is our clientId?', clientGridLayout.children[i].clientId);
        try { 
          if (isOnDesktop(clientGridLayout.children[i].client)) {
            cc++;
          }
        }
        catch(error) {}
      }
      //console.log(cc);
      return cc;
    }

    function isOnDesktop(c) {
      if (c.desktop-1 == clientContainer.desktop) {
        return true;
      } else {
        return false;
      }
      return false;
    }

    function clientsOnDesktop() {
      var clients = [];
      for (var i = 0; i < workspace.clients.length; i++) {
        if (workspace.clients[i].desktop-1 == clientContainer.desktop) {

          clients.push(workspace.clients[i]);
        }
      }
      return clients;
    }

    Repeater {
      model: workspace.clients  /*{
        var clientArray = [];
        for (var i = 0; i < workspace.clients.length; i++) {
          if (workspace.clients[i].desktop-1 == clientContainer.desktop) {
            clientArray.push(workspace.clients[i]);
          }
        }
        console.log('HOW MANY DID WE HAVE?');
        console.log(clientArray);
        return clientArray;
      }*/
      id: repeaterItem

      ClientThumbnail {
        id: loader
        visible: clientContainer.visible
        height: 0
        width: 0
        client: model
        clientId: model.internalId
        desktop: model.desktop-1
        clientRatio: model.width / model.height
        //Layout.fillWidth: true
        //Layout.fillHeight: true
        Component.onCompleted: {
          //console.log('get fucked');
          //console.log(loader.client);
          if (model.desktop-1 == clientContainer.desktop) {
            clientGridLayout.onDesktop++;
            loader.visible = true;
            var h = Math.ceil(clientContainer.height / (clientGridLayout.rows));
            var w = Math.ceil(clientContainer.width / (clientGridLayout.columns));
            loader.resizeClient(h, w);
            //loader.visible = clientContainer.visible;
            //loader.height = Math.ceil(clientContainer.height / clientGridLayout.rows);
            //loader.width = Math.ceil(clientContainer.width / clientGridLayout.columns);
          } else {
          //if (model.desktop-1 != clientContainer.desktop) {
            //loader.parent = clientContainer;
            //loader.opacity = 0;
            //loader.destroy();
          }
        }
      }
    }

    onChildrenChanged: {
      //console.log('CHILDREN HAVE CHANGED!');

      clientGridLayout.rows = _returnMatrixSize();
      clientGridLayout.columns = _returnMatrixSize();
      //console.log('children!');
      //for (var i = 0; i < repeaterItem.count; i++) {
      //  if (repeaterItem.itemAt(i).currentDesktop == clientContainer.desktop) {
      for (var i = 0; i < clientGridLayout.children.length; i++) {
        if (clientGridLayout.children[i].desktop == clientContainer.desktop) {
          //cc++;
          //console.log(clientGridLayout.children[i]);
          //console.log("RESIZING!");
          var h = Math.ceil(clientContainer.height / (clientGridLayout.rows));
          var w = Math.ceil(clientContainer.width / (clientGridLayout.columns));
          clientGridLayout.children[i].resizeClient(h, w);
          //clientGridLayout.children[i].visible = clientContainer.visible;
          //clientGridLayout.children[i].height = Math.ceil(clientContainer.height / (clientGridLayout.rows));
          //clientGridLayout.children[i].width = Math.ceil(clientContainer.width / (clientGridLayout.columns));
        }
      }
    }

    onVisibleChanged: {
      console.log("CLIENTS HAVE CHANGED!", visible);
      for (var i = 0; i < clientGridLayout.children.length; i++) {
        clientGridLayout.children[i].visible = visible;
      }
    }

    function _returnMatrixSize() {
      // Figure out how many we have on the desktop, then calculate an
      // an appropriate row x column size.
      //return 1;
      var oD = clientGridLayout._onDesktop(); // _onDesktop();
      //console.log('How many on desktop?');
      //console.log(oD);
      // Just do it manually for the moment; not elegant, but effective.
      // Not sure what math library I'd need and I'm feeling lazy.
      if (oD <= 1) {
        return 1
      } else {
        return Math.ceil(Math.sqrt(oD));
      }
    }

    Component.onCompleted: {
      clientGridLayout.onDesktop = _onDesktop();
      clientContainer.isMain = true;
      clientContainer.visible = true;
      workspace.clientAdded.connect(addNewClient);
      workspace.clientRemoved.connect(removeClients);
    }

    function removeClients(c) {
      // remove the client
      if (c.desktop-1 == clientContainer.desktop) {
        clientGridLayout.onDesktop -= 1;
      }
    }

    function addNewClient(c) {
      console.log("Oh yeah we have clients");
      if (c) {
        //console.log("c exists");
        //console.log(c.desktop-1);
        if (c.desktop-1 == clientContainer.desktop) {
          clientGridLayout.onDesktop += 1;
          var component = Qt.createComponent('ClientThumbnail.qml');
          //console.log("DOING IT ON DESKTOP!");
          //console.log(clientContainer.desktop);
          var new_client = component.createObject(clientGridLayout, {'client': c, 'clientId': c.internalId, 'desktop': clientContainer.desktop, 'visible': true,  'clientRatio': c.width / c.height});
          var h = Math.ceil(clientContainer.height / (clientGridLayout.rows));
          var w = Math.ceil(clientContainer.width / (clientGridLayout.columns));
          new_client.resizeClient(h, w);
          //console.log(new_client)
        }
      }
    }
  }


  Timer {
    id: makeVisibleTimer
    interval: 300
    onTriggered: {
      clientContainer.visible = true;
    }
  }

  function hideOnDeactive() {
    if (mainBackground.state == 'invisible') {
        clientContainer.visible = false;
    } else {
      //swapGrids();
    }
  }

  function swapGrids(oldDesktop, newDesktop) {
    //console.log('WHICH ONE IS WHICH!?');
    //console.log(oldDesktop, newDesktop);
      // Show everything except for the current desktop and the one we're transitioning into.
      if (!clientContainer.isLarge) {
        if (workspace.desktop-1 == clientContainer.desktop) {
          clientContainer.visible = true;
          //makeVisibleTimer.stop();
        }
        if (oldDesktop-1 == clientContainer.desktop) {
          //if (oldDesktop-1 < clientContainer.desktop || oldDesktop+1 < clientContainer.desktop) {
            clientContainer.visible = true;
            //makeVisibleTimer.restart();
          //}
        }
      } else {
        // Hide everything except for the current desktop and the one we're transitioning into.
        if (workspace.desktop-1 != clientContainer.desktop) {
          clientContainer.visible = false;
        } else {
          clientContainer.visible = true;
        }

      }
  }
}
