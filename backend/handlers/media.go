package handlers

import (
	"bill-update-backend/database"
	"bill-update-backend/models"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

var uploadDir = "./uploads/media"

func init() {
	os.MkdirAll(uploadDir, 0755)
}

func UploadMedia(c *gin.Context) {
	deviceID := c.PostForm("device_id")
	if deviceID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "device_id required"})
		return
	}

	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	defer file.Close()

	timestamp := time.Now().UnixMilli()
	saveName := fmt.Sprintf("%d_%s", timestamp, header.Filename)
	savePath := filepath.Join(uploadDir, saveName)

	out, err := os.Create(savePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer out.Close()

	written, _ := io.Copy(out, file)

	media := models.MediaFile{
		DeviceID: deviceID,
		FileName: header.Filename,
		FilePath: savePath,
		FileType: header.Header.Get("Content-Type"),
		FileSize: written,
	}
	database.DB.Create(&media)

	c.JSON(http.StatusOK, media)
}

func GetDeviceMedia(c *gin.Context) {
	deviceID := c.Param("device_id")
	var media []models.MediaFile
	database.DB.Where("device_id = ?", deviceID).Order("created_at desc").Find(&media)
	c.JSON(http.StatusOK, gin.H{"media": media})
}
