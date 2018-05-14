import QtQuick 2.7
//import org.kde.kwin 2.0 as KWin
//import org.kde.kwin 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma

// This is how we get the activity background.
import org.kde.plasma.activityswitcher 1.0 as ActivitySwitcher
import org.kde.activities 0.1 as Activities

Repeater {
	id: activityRepeater
	// This will generate all of our activities.  We can then iterate through
	// and get information about our activities at will.
	model: ActivitySwitcher.Backend.runningActivitiesModel()

	Item {
		// We just want our activities and background objects to display.
		id: newRepeater
		property string activityId: model.id
		property string background: model.background
		property bool isCurrent: model.isCurrent
	}

	// We're returning the current background image.
	// Useful for drawing various things.
	function getCurrentBackground() {
		var i;
		for (i = 0; i < activityRepeater.count; i++) {
			console.log('Testing activity model');
			//console.log(model[i].id);
			console.log(Object.getOwnPropertyNames(activityRepeater.itemAt(i)));
			if (activityRepeater.itemAt(i).isCurrent == true) {
				console.log(activityRepeater.itemAt(i).background);
				return activityRepeater.itemAt(i).background;
			}
		}
		return '';
	}
}
