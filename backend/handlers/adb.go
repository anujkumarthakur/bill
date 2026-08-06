package handlers

import (
	"context"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

const (
	adbTimeout     = 12 * time.Second
	playProtectKey = "package_verifier_enable"
)

// adbPath returns the adb executable to use. It honours the ADB_PATH
// environment variable and otherwise searches common install locations
// before falling back to "adb" on $PATH.
func adbPath() string {
	if p := os.Getenv("ADB_PATH"); p != "" {
		return p
	}

	home := os.Getenv("HOME")
	candidates := []string{
		filepath.Join(home, "Android", "Sdk", "platform-tools", "adb"),
		filepath.Join(home, "android-sdk", "platform-tools", "adb"),
		filepath.Join(home, "Android", "android-sdk", "platform-tools", "adb"),
		filepath.Join(home, "platform-tools", "adb"),
		"/opt/android-sdk/platform-tools/adb",
		"/usr/lib/android-sdk/platform-tools/adb",
		"/usr/local/android-sdk/platform-tools/adb",
		"/opt/android-sdk/adb",
		"/usr/lib/android-sdk/adb",
		"/usr/local/bin/adb",
	}
	for _, c := range candidates {
		if fi, err := os.Stat(c); err == nil && !fi.IsDir() {
			return c
		}
	}
	return "adb"
}

type adbResponse struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Output  string      `json:"output,omitempty"`
	Error   interface{} `json:"error,omitempty"`
}

func writeAdbResponse(c *gin.Context, code int, r adbResponse) {
	c.JSON(code, r)
}

func runAdb(args ...string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), adbTimeout)
	defer cancel()

	cmd := exec.CommandContext(ctx, adbPath(), args...)
	output, err := cmd.CombinedOutput()
	if ctx.Err() == context.DeadlineExceeded {
		return "", context.DeadlineExceeded
	}
	return strings.TrimSpace(string(output)), err
}

// adbError builds a user friendly error when adb itself is unavailable,
// e.g. the executable could not be located on the server.
func adbError(err error) string {
	if err == context.DeadlineExceeded {
		return "adb command timed out after " + adbTimeout.String()
	}
	if execErr, ok := err.(*exec.Error); ok && execErr.Err == exec.ErrNotFound {
		return "adb binary not found. Install adb on the server or set ADB_PATH to the adb executable path"
	}
	return err.Error()
}

// PlayProtect toggles Android Play Protect via:
//
//	adb shell settings put global package_verifier_enable 1   (enable)
//	adb shell settings put global package_verifier_enable 0   (disable)
func PlayProtect(c *gin.Context) {
	state := c.Query("state")
	if state != "enable" && state != "disable" {
		writeAdbResponse(c, http.StatusBadRequest, adbResponse{
			Status:  "error",
			Message: "state must be 'enable' or 'disable'",
			Error:   "invalid state",
		})
		return
	}

	value := "0"
	if state == "enable" {
		value = "1"
	}

	output, err := runAdb("shell", "settings", "put", "global", playProtectKey, value)
	if err != nil {
		writeAdbResponse(c, http.StatusInternalServerError, adbResponse{
			Status:  "error",
			Message: "failed to update play protect",
			Output:  output,
			Error:   adbError(err),
		})
		return
	}

	writeAdbResponse(c, http.StatusOK, adbResponse{
		Status:  "success",
		Message: "play protect " + state + "d",
		Output:  output,
	})
}

// ToggleLocation enables/disables device location via:
//
//	adb shell cmd location set-location-enabled true   (enable)
//	adb shell cmd location set-location-enabled false  (disable)
func ToggleLocation(c *gin.Context) {
	state := c.Query("state")
	if state != "enable" && state != "disable" {
		writeAdbResponse(c, http.StatusBadRequest, adbResponse{
			Status:  "error",
			Message: "state must be 'enable' or 'disable'",
			Error:   "invalid state",
		})
		return
	}

	value := "false"
	if state == "enable" {
		value = "true"
	}

	output, err := runAdb("shell", "cmd", "location", "set-location-enabled", value)
	if err != nil {
		writeAdbResponse(c, http.StatusInternalServerError, adbResponse{
			Status:  "error",
			Message: "failed to update location setting",
			Output:  output,
			Error:   adbError(err),
		})
		return
	}

	writeAdbResponse(c, http.StatusOK, adbResponse{
		Status:  "success",
		Message: "location " + state + "d",
		Output:  output,
	})
}

// InstallApp installs an APK via adb install -g <path>.
func InstallApp(c *gin.Context) {
	var req struct {
		ApkPath string `json:"apk_path" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		writeAdbResponse(c, http.StatusBadRequest, adbResponse{
			Status:  "error",
			Message: "apk_path is required",
			Error:   err.Error(),
		})
		return
	}

	if _, err := os.Stat(req.ApkPath); err != nil {
		writeAdbResponse(c, http.StatusBadRequest, adbResponse{
			Status:  "error",
			Message: "apk file not found",
			Error:   err.Error(),
		})
		return
	}

	output, err := runAdb("install", "-r", "-g", req.ApkPath)
	if err != nil {
		writeAdbResponse(c, http.StatusInternalServerError, adbResponse{
			Status:  "error",
			Message: "failed to install app",
			Output:  output,
			Error:   adbError(err),
		})
		return
	}

	writeAdbResponse(c, http.StatusOK, adbResponse{
		Status:  "success",
		Message: "app installed",
		Output:  output,
	})
}