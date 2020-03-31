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
  property var rows: clientGridLayout._returnMatrixSize()
  property var columns: clientGridLayout._returnMatrixSize()
  height: parent.height
  width: parent.width

  GridLayout {
    id: clientGridLayout
    rows: _returnMatrixSize()
    columns: _returnMatrixSize()
    height: parent.height
    width: parent.width
    property int onDesktop: 0
    //rowSpacing: 20 * (clientContainer.height/dashboard.screenHeight)
    //scale: 1
    //flow: GridLayout.TopToBottom

    function _onDesktop() {
      var cc = 0;
      for (var i = 0; i < clientGridLayout.children.length; i++) {
        if (clientGridLayout.children[i].currentDesktop == clientContainer.desktop) {
          cc++;
        }
      }
      return cc;
    }

    Repeater {
      model: workspace.clients /*{
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
        visible: false
        height: 0
        width: 0
        client: model
        clientId: model.internalId
        currentDesktop: model.desktop-1
        Component.onCompleted: {
          console.log('get fucked');
          console.log(loader.client);
          if (model.desktop-1 == clientContainer.desktop) {
            clientGridLayout.onDesktop++;
            loader.visible = true;
            loader.height = Math.ceil(clientContainer.height / clientGridLayout.rows);
            loader.width = Math.ceil(clientContainer.width / clientGridLayout.columns);
          } else {
            // reparent to somewhere else.  Basically, don't keep it in the grid.
            loader.parent = clientContainer;
            //loader.client = '';
            //loader.clientId = '';
            //loader.currentDesktop = 0;
            //loader.destroy();
          }
        }
      }
    }

    onChildrenChanged: {
      console.log('CHILDREN HAVE CHANGED');
      rows = _returnMatrixSize();
      columns = _returnMatrixSize();
      //console.log('children!');
      for (var i = 0; i < repeaterItem.count; i++) {
        if (repeaterItem.itemAt(i).currentDesktop == clientContainer.desktop) {
          //cc++;
          repeaterItem.itemAt(i).height = Math.ceil(clientContainer.height / clientGridLayout.rows);
          repeaterItem.itemAt(i).width = Math.ceil(clientContainer.width / clientGridLayout.columns);
        }
      }
    }

    function _returnMatrixSize() {
      // Figure out how many we have on the desktop, then calculate an
      // an appropriate row x column size.
      //return 1;
      var oD = _onDesktop();
      console.log('How many on desktop?');
      console.log(oD);
      // Just do it manually for the moment; not elegant, but effective.
      // Not sure what math library I'd need and I'm feeling lazy.
      if (oD <= 1) {
        return 1
      } else {
        return Math.ceil(Math.sqrt(oD));
      }
    }

    Component.onCompleted: {
      clientContainer.isMain = true;
      clientContainer.visible = true;
      workspace.clientAdded.connect(checkForNewClients);
    }

    function checkForNewClients(c) {
      console.log("WE CREATED NEW CLIENTS!");
      console.log(c);
      if (c.desktop-1 == clientContainer.desktop) {
        console.log('AND IT IS ON THIS DESKTOP!dol');
        var component = Qt.createComponent('ClientThumbnail.qml');
        var new_client = component.createObject(null, {'client': c, 'clientId': c.internalId, 'currentDesktop': clientContainer.desktop, 'visible': true});
        //new_client.client = c;
        console.log('NEW CLIENT CREATED');
        console.log(new_client.client, c, c.internalId);
        new_client.parent = clientGridLayout;
        new_client.height = Math.ceil(clientContainer.height / clientGridLayout.rows);
        new_client.width = Math.ceil(clientContainer.width / clientGridLayout.columns);
        console.log(new_client.parent);
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
        if (workspace.currentDesktop-1 == clientContainer.desktop) {
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
        if (workspace.currentDesktop-1 != clientContainer.desktop) {
          clientContainer.visible = false;
        } else {
          clientContainer.visible = true;
        }

      }
  }
}
