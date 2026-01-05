package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/xuri/excelize/v2"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

func main() {
	a := app.New()
	w := a.NewWindow("宽乐健康-数据导出工具 v0.1")
	w.Resize(fyne.NewSize(750, 700))

	// === UI 输入框 ===
	host := widget.NewEntry()
	host.SetText("127.0.0.1")
	//host.SetPlaceHolder("数据库主机地址")

	port := widget.NewEntry()
	port.SetText("3306")
	//port.SetPlaceHolder("端口号")

	dbname := widget.NewEntry()
	dbname.SetText("kyuniformstandard")
	//dbname.SetPlaceHolder("数据库名")

	user := widget.NewEntry()
	user.SetText("kyjk")
	//user.SetPlaceHolder("用户名")

	pass := widget.NewPasswordEntry()
	pass.SetText("Kyjk123456*")
	//pass.SetPlaceHolder("密码")

	filenamePrefix := widget.NewEntry()
	filenamePrefix.SetText("report")
	//filenamePrefix.SetPlaceHolder("请输入文件名前缀（可选）")

	// 日志计数
	logText := ""
	logLinesCount := 0
	logCountLabel := widget.NewLabel("日志行数: 0")

	// 日志显示 Label + Scroll
	logLabel := widget.NewLabel("")
	logLabel.Wrapping = fyne.TextWrapWord
	logContainer := container.NewScroll(logLabel)
	logContainer.SetMinSize(fyne.NewSize(730, 400))

	// 日志函数（线程安全，自动滚动）
	log := func(msg string) {
		fyne.Do(func() {
			logText += time.Now().Format("15:04:05 ") + msg + "\n"
			logLabel.SetText(logText)
			logContainer.ScrollToBottom()
			logLinesCount++
			logCountLabel.SetText("日志行数: " + strconv.Itoa(logLinesCount))
			logCountLabel.Refresh()
			// w.SetTitle("MySQL 报表导出工具 - 日志行数: " + strconv.Itoa(logLinesCount))
		})
	}

	// 执行导出按钮
	var btn *widget.Button
	btn = widget.NewButton("执行导出", func() {
		btn.Disable()
		btn.SetText("导出中...")

		logLinesCount = 0
		logText = ""
		logLabel.SetText("")
		logCountLabel.SetText("日志行数: 0")

		log("开始导出...")

		go func() {
			defer func() {
				fyne.Do(func() {
					btn.Enable()
					btn.SetText("执行导出")
				})
			}()

			dsn := fmt.Sprintf(
				"%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=true",
				user.Text, pass.Text, host.Text, port.Text, dbname.Text,
			)

			prefix := filenamePrefix.Text
			if prefix == "" {
				prefix = "report"
			}
			prefix = sanitizeFilename(prefix)

			runExport(dsn, prefix, log)
		}()
	})

	// 清空日志按钮
	clearBtn := widget.NewButton("清空日志", func() {
		fyne.Do(func() {
			logText = ""
			logLabel.SetText("")
			logLinesCount = 0
			logCountLabel.SetText("日志行数: 0")
			logCountLabel.Refresh()
			w.SetTitle("MySQL 报表导出工具")
		})
	})

	// 打开输出文件夹按钮
	openFolderBtn := widget.NewButton("打开输出文件夹", func() {
		go func() {
			outputDir := "output"
			absPath, _ := filepath.Abs(outputDir)
			_ = os.MkdirAll(outputDir, 0755)

			var cmd *exec.Cmd
			switch runtime.GOOS {
			case "windows":
				cmd = exec.Command("explorer", absPath)
			case "darwin":
				cmd = exec.Command("open", absPath)
			case "linux":
				cmd = exec.Command("xdg-open", absPath)
			default:
				log("无法自动打开文件夹，请手动访问: " + absPath)
				return
			}

			if err := cmd.Start(); err != nil {
				log("打开文件夹失败: " + err.Error())
				log("请手动访问: " + absPath)
			} else {
				log("已打开输出文件夹: " + absPath)
			}
		}()
	})

	// 使用网格布局
	form := container.NewVBox(
		widget.NewLabelWithStyle("数据库连接配置", fyne.TextAlignCenter, fyne.TextStyle{Bold: true}),
		container.NewGridWithColumns(2,
			widget.NewLabel("主机:"), host,
			widget.NewLabel("端口:"), port,
			widget.NewLabel("数据库:"), dbname,
			widget.NewLabel("用户名:"), user,
			widget.NewLabel("密码:"), pass,
			widget.NewLabel("文件名前缀:"), filenamePrefix,
		),
		container.NewVBox(
			widget.NewLabel("文件名格式: [前缀]_[日期]_[时间].xlsx"),
			widget.NewLabel("例如: report_20240101_143000.xlsx"),
		),
	)

	// 按钮容器
	buttonContainer := container.NewHBox(
		btn,
		widget.NewSeparator(),
		clearBtn,
		widget.NewSeparator(),
		openFolderBtn,
	)

	// Border布局组合
	content := container.NewBorder(
		container.NewVBox(
			form,
			widget.NewSeparator(),
			container.NewCenter(buttonContainer),
			widget.NewSeparator(),
		),
		container.NewHBox(
			logCountLabel,
			widget.NewButton("复制日志", func() {
				fyne.Do(func() {
					w.Clipboard().SetContent(logLabel.Text)
					log("日志已复制到剪贴板")
				})
			}),
			widget.NewButton("保存日志", func() {
				go func() {
					_ = os.MkdirAll("logs", 0755)
					filename := "export_log_" + time.Now().Format("20060102_150405") + ".txt"
					logFilePath := filepath.Join("logs", filename)
					if err := os.WriteFile(logFilePath, []byte(logLabel.Text), 0644); err != nil {
						log("保存日志失败: " + err.Error())
					} else {
						absPath, _ := filepath.Abs(logFilePath)
						log("日志已保存到: " + absPath)
					}
				}()
			}),
		),
		nil,
		nil,
		container.NewVBox(
			widget.NewLabelWithStyle("执行日志", fyne.TextAlignLeading, fyne.TextStyle{Bold: true}),
			logContainer,
		),
	)

	w.SetContent(content)
	w.ShowAndRun()
}

// =====================
// 导出逻辑
// =====================
func runExport(dsn string, prefix string, log func(string)) {
	log("开始连接数据库...")

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log("✗ 数据库连接失败: " + err.Error())
		return
	}
	defer db.Close()

	db.SetMaxOpenConns(5)
	db.SetMaxIdleConns(2)

	if err := db.Ping(); err != nil {
		log("✗ 数据库连接测试失败: " + err.Error())
		return
	}
	log("✓ 数据库连接成功")

	sqlFiles := []string{"drop.sql", "create.sql", "report.sql"}
	for _, file := range sqlFiles {
		if _, err := os.Stat(file); os.IsNotExist(err) {
			log(fmt.Sprintf("✗ SQL文件不存在: %s", file))
			return
		}
	}

	// DROP
	log("执行DROP操作...")
	dropSQL, err := readSQL("drop.sql")
	if err != nil {
		log("✗ 读取 drop.sql 失败: " + err.Error())
		return
	}
	if _, err := db.Exec(dropSQL); err != nil {
		log("✗ DROP 失败: " + err.Error())
		return
	}
	log("✓ DROP 成功")

	// CREATE
	log("执行CREATE操作...")
	createSQL, err := readSQL("create.sql")
	if err != nil {
		log("✗ 读取 create.sql 失败: " + err.Error())
		return
	}
	if _, err := db.Exec(createSQL); err != nil {
		log("✗ CREATE 失败: " + err.Error())
		return
	}
	log("✓ CREATE 成功")

	// QUERY
	log("执行查询操作...")
	selectSQL, err := readSQL("report.sql")
	if err != nil {
		log("✗ 读取 report.sql 失败: " + err.Error())
		return
	}

	startTime := time.Now()
	rows, err := db.Query(selectSQL)
	if err != nil {
		log("✗ 查询失败: " + err.Error())
		return
	}
	defer rows.Close()

	columns, _ := rows.Columns()
	log(fmt.Sprintf("查询到 %d 个字段", len(columns)))

	f := excelize.NewFile()
	defer func() {
		if err := f.Close(); err != nil {
			log("警告: 关闭Excel文件失败: " + err.Error())
		}
	}()

	sw, err := f.NewStreamWriter("Sheet1")
	if err != nil {
		log("✗ 创建Excel流写入器失败: " + err.Error())
		return
	}

	// 表头
	head := make([]interface{}, len(columns))
	for i, c := range columns {
		head[i] = c
	}
	if err := sw.SetRow("A1", head); err != nil {
		log("✗ 写入表头失败: " + err.Error())
		return
	}
	log("✓ Excel表头写入成功")

	values := make([]interface{}, len(columns))
	ptrs := make([]interface{}, len(columns))
	for i := range values {
		ptrs[i] = &values[i]
	}

	rowIndex := 2
	recordCount := 0
	lastLogTime := time.Now()

	log("开始写入数据到Excel...")
	for rows.Next() {
		if err := rows.Scan(ptrs...); err != nil {
			log(fmt.Sprintf("✗ 读取第 %d 行数据失败: %v", rowIndex-1, err))
			continue
		}

		row := make([]interface{}, len(columns))
		for i, v := range values {
			if b, ok := v.([]byte); ok {
				row[i] = string(b)
			} else if v == nil {
				row[i] = ""
			} else {
				row[i] = fmt.Sprint(v)
			}
		}

		cell, _ := excelize.CoordinatesToCellName(1, rowIndex)
		if err := sw.SetRow(cell, row); err != nil {
			log(fmt.Sprintf("✗ 写入第 %d 行到Excel失败: %v", rowIndex-1, err))
		}
		rowIndex++
		recordCount++

		if recordCount%500 == 0 || time.Since(lastLogTime) > 5*time.Second {
			log(fmt.Sprintf("↻ 已处理 %d 条记录...", recordCount))
			lastLogTime = time.Now()
		}
	}

	if err = rows.Err(); err != nil {
		log("✗ 遍历查询结果时出错: " + err.Error())
	}

	if err := sw.Flush(); err != nil {
		log("✗ 刷新Excel流失败: " + err.Error())
		return
	}

	_ = os.MkdirAll("output", 0755)
	filename := prefix + "_" + time.Now().Format("20060102_150405") + ".xlsx"
	file := filepath.Join("output", filename)

	if err := f.SaveAs(file); err != nil {
		log("✗ 保存 Excel 失败: " + err.Error())
		return
	}

	elapsedTime := time.Since(startTime)
	absPath, _ := filepath.Abs(file)

	log(fmt.Sprintf("✓ 导出完成! 耗时: %.2f秒", elapsedTime.Seconds()))
	log(fmt.Sprintf("✓ 共导出 %d 行数据", recordCount))
	log(fmt.Sprintf("✓ 文件位置: %s", absPath))
	log(fmt.Sprintf("✓ 文件名: %s", filename))

	if fileInfo, err := os.Stat(file); err == nil {
		fileSizeMB := float64(fileInfo.Size()) / 1024 / 1024
		log(fmt.Sprintf("✓ 文件大小: %.2f MB", fileSizeMB))
	}

	log("=====================")
	log("导出任务完成！")
}

// 读取 SQL 文件
func readSQL(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer file.Close()

	var sqlText string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		sqlText += scanner.Text() + "\n"
	}
	return sqlText, scanner.Err()
}

// 清理文件名
func sanitizeFilename(filename string) string {
	invalidChars := []string{"\\", "/", ":", "*", "?", "\"", "<", ">", "|"}
	for _, char := range invalidChars {
		filename = strings.ReplaceAll(filename, char, "_")
	}
	filename = strings.TrimSpace(filename)
	if filename == "" {
		return "report"
	}
	return filename
}
