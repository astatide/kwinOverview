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

  GridLayout {
    id: clientGridLayout
    visible: true
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    // We dynamically update these.
    rows: _returnMatrixSize()
    columns: _returnMatrixSize()

    onRowsChanged: {
      testRows.start();
    }
    NumberAnimation { id: testRows; property: "y"; duration: 400; easing.type: Easing.OutBounce }
    NumberAnimation on columns { property: "x"; duration: 400; easing.type: Easing.OutBounce }

    //onChildrenChanged: {
    //  kwinDesktopThumbnailContainer.updateGrid();
    //}

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
      kwinDesktopThumbnailContainer.onChildrenChanged.connect(kwinDesktopThumbnailContainer.updateGrid);
      console.log(Object.getOwnPropertyNames(kwinDesktopThumbnailContainer));

    }
  }


  Timer {
    id: makeVisibleTimer
    interval: 1000
    onTriggered: {
      kwinDesktopThumbnailContainer.visible = true;
    }
  }

  function swapGrids(oldDesktop, newDesktop) {
    console.log('WHICH ONE IS WHICH!?');
    console.log(oldDesktop, newDesktop);
    /*if (kwinDesktopThumbnailContainer.isLarge) {
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
          if (currentDesktopGridThumbnailContainer.state == 'showDesktop') {
            kwinDesktopThumbnailContainer.visible = true;
          }
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
      }    } else {*/
      //if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
      //  kwinDesktopThumbnailContainer.visible = false;
      //}
      if (oldDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
        //if (oldDesktop-1 < kwinDesktopThumbnailContainer.desktop || oldDesktop+1 < kwinDesktopThumbnailContainer) {
          kwinDesktopThumbnailContainer.visible = false;
          makeVisibleTimer.restart();
        //}
      }
    //}
    //kwinDesktopThumbnailContainer.updateGrid();
  }

  function hideGrids(oldDesktop, newDesktop) {
    // If we're not the 'main', but we ARE current, we want to become visible and change our
    // x position (to the right or left, don't care right now), then animate a change to 0, 0.
    // Is this our new desktop?
    //if (workspace.currentDesktop-1 == kwinDesktopThumbnailContainer.desktop) {
    //  kwinDesktopThumbnailContainer.visible = false;
    //}
    // make the old one visible!
    if ((workspace.currentDesktop-1 != kwinDesktopThumbnailContainer.desktop) && (oldDesktop-1 == kwinDesktopThumbnailContainer.desktop)) {
      makeVisibleTimer.restart();
    }
  }

  function updateGrid() {
    // This function is responsible for resizing all the children.  The children currently call this function when necessary,
    // which is not ideal.  I would like for the children to be ignorant of their size and parent, and instead let the grid clients
    // handle all of it.  The work around is working, at least.
    clientGridLayout.rows = clientGridLayout._returnMatrixSize();
    clientGridLayout.columns = clientGridLayout._returnMatrixSize();
    console.log('BEGIN: YOU SHOULD SEE THIS');
    var c;
    for (c = 0; c < clientGridLayout.children.length; c++) {
      clientGridLayout.children[c].height = kwinDesktopThumbnailContainer.height / (clientGridLayout.columns);
      clientGridLayout.children[c].width = kwinDesktopThumbnailContainer.width / (clientGridLayout.rows);
      clientGridLayout.children[c].originalHeight = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].originalWidth = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].children[1].height = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].children[1].width = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].height = kwinDesktopThumbnailContainer.height / clientGridLayout._returnMatrixSize();
      clientGridLayout.children[c].children[1].width = kwinDesktopThumbnailContainer.width / clientGridLayout._returnMatrixSize();
    }
    console.log('END: YOU SHOULD SEE THIS');
  }
}
