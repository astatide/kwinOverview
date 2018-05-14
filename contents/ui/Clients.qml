import QtQuick 2.2
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

  Grid {
    id: clientGridLayout
    visible: true
    scale: 1

    anchors.verticalCenter: parent.verticalCenter
    //rows: { return _returnMatrixSize() }
    // We dynamically update these.
    rows: 0
    columns: 0
    // No order guaranteed, here.
    //columns: { return _returnMatrixSize() }
    // These should apparently have their own thread.

    add: Transition {
      NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
    }

    move: Transition {
        NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce }
    }

    onRowsChanged: {
      testRows.start();
    }
    NumberAnimation { id: testRows; property: "y"; duration: 400; easing.type: Easing.OutBounce }
    NumberAnimation on columns { property: "x"; duration: 400; easing.type: Easing.OutBounce }

    onChildrenChanged: {
      kwinDesktopThumbnailContainer.updateGrid();
    }

    function _onDesktop() {
      var c;
      var oD = 0;
      for (c = 0; c < workspace.clientList().length; c++) {
        if (workspace.clientList()[c].desktop-1 == desktop && !workspace.clientList()[c].dock) {
          oD++;
        }
      }
      if (clientGridLayout.onDesktop == 0) {
        oD = 1;
      }
      return oD;
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
      //updateClients();
      kwinDesktopThumbnailContainer.updateGrid();
      // We do want to change when a client changes desktops, but.
      if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
        if (kwinDesktopThumbnailContainer.isLarge) {
          kwinDesktopThumbnailContainer.isMain = true;
          kwinDesktopThumbnailContainer.visible = true;
        } else {
          kwinDesktopThumbnailContainer.isMain = true;
          kwinDesktopThumbnailContainer.visible = false;
        }
      }
      if (kwinDesktopThumbnailContainer.isLarge) {
        // If we're the main one, we actually just want to go invisible and let the other one in.
        workspace.currentDesktopChanged.connect(kwinDesktopThumbnailContainer.swapGrids);
      } else {
        // If we're small, don't paint again.  Turns out that's rather slow.
        // This is really just for performance reasons.
        workspace.currentDesktopChanged.connect(function() {
          if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
            kwinDesktopThumbnailContainer.visible = false;
          } else {
            kwinDesktopThumbnailContainer.visible = true;
          }
        });
      }
      // The clients destroy/add themselves, so.
      //workspace.clientAdded.connect(kwinDesktopThumbnailContainer.updateGrid);
      //workspace.clientRemoved.connect(kwinDesktopThumbnailContainer.updateGrid);
      // We'll probably sort this out later, as well.
      workspace.currentActivityChanged.connect(kwinDesktopThumbnailContainer.updateGrid);
      workspace.currentActivityChanged.connect(kwinDesktopThumbnailContainer.updateGrid);
    }
  }

  PropertyAnimation {
    id: moveMainToLeft
    target: kwinDesktopThumbnailContainer
    //duration: 100
    running: false
    property: 'x'
    to: -dashboard.screenWidth
    from: 0
    easing.amplitude: 2
    easing.type: Easing.InOutQuad
    onStopped: {
      kwinDesktopThumbnailContainer.visible = false;
    }
  }
  PropertyAnimation {
    id: moveMainToRight
    target: kwinDesktopThumbnailContainer
    //duration: 100
    running: false
    property: 'x'
    to: dashboard.screenWidth
    from: 0
    easing.amplitude: 2
    easing.type: Easing.InOutQuad
    onStopped: {
      kwinDesktopThumbnailContainer.visible = false;
    }
  }
  PropertyAnimation {
    id: moveNewToLeft
    target: kwinDesktopThumbnailContainer
    //duration: 100
    property: 'x'
    running: false
    from: dashboard.screenWidth
    to: 0
    easing.amplitude: 2
    easing.type: Easing.InOutQuad
  }
  PropertyAnimation {
    id: moveNewToRight
    target: kwinDesktopThumbnailContainer
    //duration: 100
    property: 'x'
    running: false
    from: -dashboard.screenWidth
    to: 0
    easing.amplitude: 2
    easing.type: Easing.InOutQuad
  }

  function swapGrids(oldDesktop, newDesktop) {
    console.log('WHICH ONE IS WHICH!?');
    console.log(oldDesktop, newDesktop);
    // If we're not the 'main', but we ARE current, we want to become visible and change our
    // x position (to the right or left, don't care right now), then animate a change to 0, 0.
    if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
      if (!kwinDesktopThumbnailContainer.isMain) {
        // We need to know which way we're moving.  But, ah, hmmm.
        // Which one is the old one?
        if (oldDesktop-1 < kwinDesktopThumbnailContainer.desktop) {
          moveNewToLeft.restart();
        } else {
          moveNewToRight.restart();
        }
        kwinDesktopThumbnailContainer.isMain = true;
        kwinDesktopThumbnailContainer.visible = true;
        //kwinDesktopThumbnailContainer.x = -dashboard.screenWidth;
      }
    }
    if (isMain && workspace.currentDesktop-1 != kwinDesktopThumbnailContainer.desktop) {
        // Now, handle moving the OTHER one.
        if (workspace.currentDesktop-1 > kwinDesktopThumbnailContainer.desktop) {
          moveMainToLeft.restart();
        } else {
          moveMainToRight.restart();
        }
        kwinDesktopThumbnailContainer.isMain = false;
        //kwinDesktopThumbnailContainer.x = dashboard.screenWidth;
    }
  }

  function updateGrid() {
    // Check how large our grid needs to be, then reparent on to our current grid.
    clientGridLayout.rows = clientGridLayout._returnMatrixSize();
    clientGridLayout.columns = clientGridLayout._returnMatrixSize();
    console.log('BEGIN: YOU SHOULD SEE THIS');
    var c;
    for (c = 0; c < clientGridLayout.children.length; c++) {
      //var client = clientGridLayout.children[c];
      //console.log('How many children do we have?');
      //console.log(clientGridLayout.children.length);
      //console.log('How big are we?');
      //console.log(clientGridLayout._returnMatrixSize());
      //console.log(kwinDesktopThumbnailContainer.width, kwinDesktopThumbnailContainer.height);
      clientGridLayout.children[c].width = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].height = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].originalWidth = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].originalHeight = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      // Run the growth animation!
      clientGridLayout.children[c].runGrowthAnim();
      //console.log(Object.getOwnPropertyNames(clientGridLayout.children[c]));
    }
    console.log('END: YOU SHOULD SEE THIS');
  }
}
