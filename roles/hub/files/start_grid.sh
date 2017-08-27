#!/bin/sh
java -cp *:. org.openqa.grid.selenium.GridLauncher -jar appium-grid.jar -port 4444 -role hub -hubConfig hubconfig.json >> gridhub.log 2>&1 &
