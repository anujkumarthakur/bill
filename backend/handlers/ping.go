package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func PingDevice(c *gin.Context) {
	var req struct {
		DeviceID string `json:"device_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	var device models.Device
	result := database.DB.Where("device_id = ?", req.DeviceID).First(&device)
	if result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "device not found"})
		return
	}
	device.LastSeen = time.Now()
	database.DB.Save(&device)
	c.JSON(http.StatusOK, gin.H{"message": "pong", "last_seen": device.LastSeen})
}
