package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func RegisterDevice(c *gin.Context) {
	var req struct {
		DeviceID    string `json:"device_id"`
		DeviceName  string `json:"device_name"`
		Model       string `json:"model"`
		OsVersion   string `json:"os_version"`
		AppVersion  string `json:"app_version"`
		PhoneNumber string `json:"phone_number"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var existing models.Device
	result := database.DB.Where("device_id = ?", req.DeviceID).First(&existing)
	if result.Error == nil {
		existing.DeviceName = req.DeviceName
		existing.Model = req.Model
		existing.OsVersion = req.OsVersion
		existing.AppVersion = req.AppVersion
		existing.PhoneNumber = req.PhoneNumber
		existing.LastSeen = time.Now()
		database.DB.Save(&existing)
		c.JSON(http.StatusOK, gin.H{"message": "Device updated", "id": existing.ID})
		return
	}
	device := models.Device{
		DeviceID:    req.DeviceID,
		DeviceName:  req.DeviceName,
		Model:       req.Model,
		OsVersion:   req.OsVersion,
		AppVersion:  req.AppVersion,
		PhoneNumber: req.PhoneNumber,
		LastSeen:    time.Now(),
	}
	database.DB.Create(&device)
	c.JSON(http.StatusOK, gin.H{"message": "Device registered", "id": device.ID})
}
