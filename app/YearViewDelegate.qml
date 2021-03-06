import QtQuick 2.0
import Ubuntu.Components 1.1
import HebrewCalendar 1.0
GridView{
    HDate{
        id:hebrewDate
    }
    id: yearView
    clip: true

    property int scrollMonth;
    property bool isCurrentItem;
    property int year;

    readonly property int minCellWidth: units.gu(30)
    cellWidth: Math.floor(Math.min.apply(Math, [3, 4].map(function(n)
    { return ((width / n >= minCellWidth) ? width / n : width / 2) })))

    cellHeight: cellWidth * 1.4

    model: hebrewDate.is_leap_year(year)? 13 :12 /* months in a year */

    onYearChanged: {
        scrollMonth = 0;
        var today =  hebrewDate.today();
        if(year === hebrewDate.getYear(today)) {
            scrollMonth = hebrewDate.getMonth(today)-1;
        }
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    //scroll in case content height changed
    onHeightChanged: {
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
    }

    Component.onCompleted: {        
        yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
     }

    Connections{
        target: yearPathView
        onScrollUp: {
            scrollMonth -= 2;
            if(scrollMonth < 0) {
                scrollMonth = 0;
            }
            yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
        }

        onScrollDown: {
            scrollMonth += 2;
            var visibleMonths = yearView.height / cellHeight;
            if( scrollMonth >= (11 - visibleMonths)) {
                scrollMonth = (11 - visibleMonths);
            }
            yearView.positionViewAtIndex(scrollMonth, GridView.Beginning);
        }
    }
    ActivityIndicator {
        visible: running
        running: yearView.isLoading
        anchors.centerIn: parent
        z:2
    }
    delegate: Loader {
        width: yearView.cellWidth
        height: yearView.cellHeight

        sourceComponent: delegateComponent
        asynchronous: !yearView.focus

        Component {
            id: delegateComponent

            Item {
                anchors.fill: parent
                anchors.margins: units.gu(0.5)

                MonthComponent {
                    id: monthComponent
                    objectName: "monthComponent" + index

                    currentMonth: {
                        var realIndex =index+1;
                                if(hebrewDate.is_leap_year(yearView.year)){
                                    if(realIndex===6)
                                        realIndex=13;
                                    else if(realIndex===7)
                                        realIndex=14;
                                    else if (realIndex>7)
                                        realIndex= realIndex-1;
                                }
                            return  hebrewDate.setHebDate(yearView.year, realIndex, 1);

                    }

                    isCurrentItem: yearView.focus

                    isYearView: true
                    anchors.fill: parent

                    dayLabelFontSize:"x-small"
                    dateLabelFontSize: "medium"
                    monthLabelFontSize: "medium"
                    yearLabelFontSize: "medium"

                    onMonthSelected: {
                        yearViewPage.monthSelected(date);
                    }
                }
            }
        }
    }
}
