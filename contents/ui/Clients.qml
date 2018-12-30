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
  id: kwinDesktopThumbnailContainer
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
  onChildrenChanged: {
    kwinDesktopThumbnailContainer.updateGrid();
  }

  Item {
    id: clientGridLayout
    //visible: true
    //anchors.verticalCenter: parent.verticalCenter
    //anchors.horizontalCenter: parent.horizontalCenter
    // We dynamically update these.
    //rows: _returnMatrixSize()
    //columns: _returnMatrixSize()
    property var rows: _returnMatrixSize()
    property var columns: _returnMatrixSize()
    height: parent.height
    width: parent.width
    property var spacing: 20 * (parent.height/dashboard.screenHeight)

    onRowsChanged: {
      testRows.start();
    }
    NumberAnimation { id: testRows; property: "y"; duration: 200; easing.type: Easing.OutBounce }
    NumberAnimation on columns { property: "x"; duration: 200; easing.type: Easing.OutBounce }

    function _onDesktop() {
      return clientGridLayout.children.length;
    }

    function _returnMatrixSize() {
      // Figure out how many we have on the desktop, then calculate an
      // an appropriate row x column size.
      var oD = _onDesktop();
      // Just do it manually for the moment; not elegant, but effective.
      // Not sure what math library I'd need and I'm feeling lazy.
      if (oD <= 1) {
        return 1
      } else {
        return Math.ceil(Math.sqrt(oD));
      }
    }

    Component.onCompleted: {
      kwinDesktopThumbnailContainer.isMain = true;
      kwinDesktopThumbnailContainer.visible = true;
      workspace.currentDesktopChanged.connect(kwinDesktopThumbnailContainer.swapGrids);
      mainBackground.onStateChanged(kwinDesktopThumbnailContainer.hideOnDeactive);
      // This doesn't seem to actually... work.  Not sure why.
      kwinDesktopThumbnailContainer.onChildrenChanged.connect(kwinDesktopThumbnailContainer.updateGrid);
      kwinDesktopThumbnailContainer.onChildrenAdded.connect(kwinDesktopThumbnailContainer.updateGrid);
      kwinDesktopThumbnailContainer.onChildrenRemoved.connect(kwinDesktopThumbnailContainer.updateGrid);

      //console.log(Object.getOwnPropertyNames(kwinDesktopThumbnailContainer));
      //kwinDesktopThumbnailContainer.swapGrids();
      //kwinDesktopThumbnailContainer.updateGrid();

    }
  }


  Timer {
    id: makeVisibleTimer
    interval: 300
    onTriggered: {
      kwinDesktopThumbnailContainer.visible = true;
    }
  }

  function hideOnDeactive() {
    if (mainBackground.state == 'invisible') {
        kwinDesktopThumbnailContainer.visible = false;
    } else {
      swapGrids();
    }
  }

  function swapGrids(oldDesktop, newDesktop) {
    //console.log('WHICH ONE IS WHICH!?');
    //console.log(oldDesktop, newDesktop);
      // Show everything except for the current desktop and the one we're transitioning into.
      if (!kwinDesktopThumbnailContainer.isLarge) {
        if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
          kwinDesktopThumbnailContainer.visible = false;
          makeVisibleTimer.stop();
        }
        if (oldDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
          //if (oldDesktop-1 < kwinDesktopThumbnailContainer.desktop || oldDesktop+1 < kwinDesktopThumbnailContainer.desktop) {
            kwinDesktopThumbnailContainer.visible = false;
            makeVisibleTimer.restart();
          //}
        }
      } else {
        // Hide everything except for the current desktop and the one we're transitioning into.
        if (workspace.currentDesktop-1 != kwinDesktopThumbnailContainer.desktop) {
          kwinDesktopThumbnailContainer.visible = false;
        } else {
          kwinDesktopThumbnailContainer.visible = true;
        }

      }
  }

  function hideGrids(oldDesktop, newDesktop) {
    // If we're not the 'main', but we ARE current, we want to become visible and change our
    // x position (to the right or left, don't care right now), then animate a change to 0, 0.
    // Is this our new desktop?
    //if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
    //  kwinDesktopThumbnailContainer.visible = false;
    //}
    // make the old one visible!
    if (!kwinDesktopThumbnailContainer.isLarge) {
      if ((workspace.currentDesktop-1 != kwinDesktopThumbnailContainer.desktop) && (oldDesktop-1 == kwinDesktopThumbnailContainer.desktop)) {
        makeVisibleTimer.restart();
      }
    }
  }

  function posClient (c) {
    // Function which calculates the appropriate x,y for client ID c.
    // We assume that we don't touch the docks.  Soooo.  We'll also calculate the appropriate size.
    var rows = clientGridLayout._returnMatrixSize();
    var cols = clientGridLayout._returnMatrixSize();
    var height = 0
    var width = 0
    var spacing = clientGridLayout.spacing;
    if (!isLarge) {
      height = kwinDesktopThumbnailContainer.height;
      width = kwinDesktopThumbnailContainer.width;
    } else {
      height = kwinDesktopThumbnailContainer.height - dashboardActivityChanger.height - dashboardDesktopChanger.height - (spacing*6);
      width = kwinDesktopThumbnailContainer.width;
    }
    // if we're large, we'll adjust for that later.
    var nHeight = (height)/rows;
    var nWidth = (width)/cols;
    // First, calculate the slot ID, then turn those into coordinates.  Also, center!
    var y = ((Math.floor(c/rows)) * (nHeight+spacing)) + (kwinDesktopThumbnailContainer.height - height)/2;
    var x = ((c % rows) * (nWidth+spacing));

    // Let's try something a little different.  See if we can pack them all into one row; if not, add another one, and recalculate.
    var d;
    var r;
    var currentWidth = 0;
    var oldRows = 1;
    rows = 1;
    cols = 1;
    for (d = 0; d < clientGridLayout.children.length; d++) {
      // See what the size would be if we stopped here.
      if (clientGridLayout.children[d].clientObject.activities == workspace.currentActivity || clientGridLayout.children[d].clientObject.activities == '') {
            currentWidth = currentWidth + ((height/(oldRows) * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) + spacing;
      }
      if ((currentWidth > kwinDesktopThumbnailContainer.width)) {
        rows = rows + 1;
        currentWidth = ((height/oldRows * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) + spacing;;
      }
      if ((oldRows < rows)) {
        oldRows = rows;
        rows = 0;
        d = 0;
      }
    }
    rows = oldRows;
    if (clientGridLayout.children.length == 1) {
        rows = 1;
    }
    var maxWidth = 0;
    for (d = 0; d < clientGridLayout.children.length; d++) {
      if (clientGridLayout.children[d].clientObject.activities == workspace.currentActivity || clientGridLayout.children[d].clientObject.activities == '') {
            maxWidth = maxWidth + ((height/rows * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) + (spacing*2);
      }
    }
    maxWidth = maxWidth / rows;

    var row = 0;
    d = 0;
    currentWidth = 0;
    var cWidth = [0];
    var cHeight = [0];
    var wAdd = [];
    for (d = 0; d < clientGridLayout.children.length; d++) {
      // See what the size would be if we stopped here.
      if (clientGridLayout.children[d].clientObject.activities == workspace.currentActivity || clientGridLayout.children[d].clientObject.activities == '') {
            currentWidth = currentWidth + ((height/(rows) * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) + spacing;
      }
      if ((currentWidth > maxWidth)) {
        //currentWidth = ((height/rows * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) + spacing;
        wAdd.push((width - (currentWidth))/2); //- ((height/(rows) * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) - spacing))/2); // - ((height/rows * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))))/2);
        currentWidth = 0;
        row = row + 1;
        //cHeight[d] = row;
        //cWidth[d] = 0
      }
      cHeight.push(row);
      cWidth.push(currentWidth);
    }
    var scaleForOne = 1;
    if (row == 0 || row == 1) {
      //cHeight = [0];
      //cWidth = [0];
      //wAdd = [0];
      wAdd.push((width - currentWidth)/2);
      /*currentWidth = 0;
      for (d = 0; d < clientGridLayout.children.length; d++) {
        // See what the size would be if we stopped here.
        if (clientGridLayout.children[d].clientObject.activities == workspace.currentActivity || clientGridLayout.children[d].clientObject.activities == '') {
              currentWidth = currentWidth + ((height * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) + spacing;
        }
        cHeight.push(0);
        //cWidth.push(currentWidth/width);
      }
      for (d = 0; d < clientGridLayout.children.length; d++) {
        // See what the size would be if we stopped here.
        //cHeight.push(0);
        cWidth.push((((clientGridLayout.children[d].width/clientGridLayout.children[d].height))) * height / (currentWidth/width));
      }
      wAdd.push((width - (currentWidth))/2); //- ((height/(rows) * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))) - spacing))/2); // - ((height/rows * (clientGridLayout.children[d].width/clientGridLayout.children[d].height))))/2);
      if (clientGridLayout.children.length != 1) {
        rows = (currentWidth/width);
        //scaleForOne = currentWidth/width;
      }*/

    }
    nHeight = (height)/rows;
    nWidth = height/rows*(clientGridLayout.children[c].width/clientGridLayout.children[c].height);
    x = ((cWidth[c]) + wAdd[cHeight[c]]);
    y = ((cHeight[c]*(nHeight+spacing)) + ((kwinDesktopThumbnailContainer.height - (height+(spacing*rows)))/2))*scaleForOne;
    if (clientGridLayout.children.length == rows && rows != 1) {
      y = y + nHeight/2
    }
    //console.log('testing width');
    //console.log(cWidth);
    return [nHeight, nWidth, x, y];
  }

  function updateGrid() {
    // This function is responsible for resizing all the children.  The children currently call this function when necessary,
    // which is not ideal.  I would like for the children to be ignorant of their size and parent, and instead let the grid clients
    // handle all of it.  The work around is working, at least.
    clientGridLayout.rows = clientGridLayout._returnMatrixSize();
    clientGridLayout.columns = clientGridLayout._returnMatrixSize();
    //console.log('BEGIN: YOU SHOULD SEE THIS');
    var c;
    for (c = 0; c < clientGridLayout.children.length; c++) {
      //clientGridLayout.children[c].updateSize((kwinDesktopThumbnailContainer.height / (clientGridLayout.columns))-clientGridLayout.spacing, (kwinDesktopThumbnailContainer.width / (clientGridLayout.rows))-clientGridLayout.spacing);
      var coords = posClient(c);
      clientGridLayout.children[c].updateSize(coords[0], coords[1]);
      // Clients are responsible for determining their grid spacing, as their dimensions must be taken into account.
      clientGridLayout.children[c].updatePos(coords[2], coords[3], clientGridLayout.rows, clientGridLayout.columns,kwinDesktopThumbnailContainer.height);
      //clientGridLayout.children[c].toggleVisible('visible');
      /*clientGridLayout.children[c].height = kwinDesktopThumbnailContainer.height / (clientGridLayout.columns);
      clientGridLayout.children[c].width = kwinDesktopThumbnailContainer.width / (clientGridLayout.rows);
      clientGridLayout.children[c].originalHeight = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].originalWidth = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].children[1].height = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].children[1].width = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].height = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].width = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();*/
      // We should also calculate the x, y pos.
    }
    //console.log('END: YOU SHOULD SEE THIS');
  }
}
