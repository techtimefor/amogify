import sys
import os
import time
from PyQt6.QtWidgets import (QApplication, QWidget, QPushButton, QVBoxLayout, 
                             QLabel, QHBoxLayout, QStackedWidget, QFrame)
from PyQt6.QtCore import Qt, QProcess, QTimer
from PyQt6.QtGui import QPixmap, QLinearGradient, QPalette, QBrush, QColor

class AmogOSGui(QWidget):
    def __init__(self):
        super().__init__()
        self.terminal_process = None
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('AmogOS Control Center')
        self.setFixedSize(700, 550)

        # 1. VISUAL GRADIENT
        palette = self.palette()
        gradient = QLinearGradient(0, 0, 0, 550)
        gradient.setColorAt(0.0, QColor(15, 15, 25))
        gradient.setColorAt(1.0, QColor(45, 10, 10))
        palette.setBrush(QPalette.ColorRole.Window, QBrush(gradient))
        self.setPalette(palette)
        self.setAutoFillBackground(True)

        # 2. STYLESHEET
        self.setStyleSheet("""
            QPushButton {
                background-color: rgba(255, 255, 255, 15);
                border: 1px solid rgba(255, 255, 255, 30);
                border-radius: 10px; color: white; padding: 15px; font-weight: bold;
            }
            QPushButton:hover { background-color: rgba(255, 255, 255, 25); }
            #amog_btn { background-color: #ff1a1a; font-size: 16px; border: none; }
            #amog_btn:hover { background-color: #ff4d4d; }
            #back_btn { background-color: #333; margin-top: 10px; }
            QLabel#title { font-size: 42px; font-weight: 900; color: white; }
        """)

        self.master_layout = QVBoxLayout(self)
        self.stack = QStackedWidget()
        
        # --- SCREEN 1: MENU ---
        self.menu_widget = QWidget()
        menu_layout = QVBoxLayout(self.menu_widget)
        menu_layout.setContentsMargins(50, 40, 50, 50)
        
        title = QLabel("Amogify")
        title.setObjectName("title")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        btn_amog = QPushButton("AMOGIFY SYSTEM")
        btn_amog.setObjectName("amog_btn")
        btn_amog.clicked.connect(lambda: self.run_terminal_task("install.sh"))
        
        btn_undo = QPushButton("UN-AMOGIFY (UNDO)")
        btn_undo.clicked.connect(lambda: self.run_terminal_task("uninstall.sh"))
        
        h_buttons = QHBoxLayout()
        btn_support = QPushButton("Support")
        btn_support.clicked.connect(lambda: self.run_terminal_task("support.sh", use_sudo=False))
        btn_about = QPushButton("About")
        btn_about.clicked.connect(lambda: self.run_terminal_task("about.sh", use_sudo=False))
        
        h_buttons.addWidget(btn_support)
        h_buttons.addWidget(btn_about)

        menu_layout.addWidget(title)
        menu_layout.addWidget(btn_amog)
        menu_layout.addWidget(btn_undo)
        menu_layout.addLayout(h_buttons)

        # --- SCREEN 2: EMBEDDED XFCE TERMINAL ---
        self.terminal_widget = QWidget()
        term_layout = QVBoxLayout(self.terminal_widget)
        
        # This frame acts as the container for xfce4-terminal
        self.terminal_container = QFrame()
        self.terminal_container.setStyleSheet("background-color: black; border: 2px solid #ff4444;")
        term_layout.addWidget(self.terminal_container)

        self.btn_back = QPushButton("BACK TO MENU")
        self.btn_back.setObjectName("back_btn")
        self.btn_back.clicked.connect(self.show_menu)
        term_layout.addWidget(self.btn_back)

        self.stack.addWidget(self.menu_widget)
        self.stack.addWidget(self.terminal_widget)
        self.master_layout.addWidget(self.stack)

        # 3. CREWMATE OVERLAY
        self.crewmate = QLabel(self)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        asset_path = os.path.normpath(os.path.join(script_dir, "assets", "amogus.webp"))
        
        if os.path.exists(asset_path):
            pix = QPixmap(asset_path)
            scaled_pix = pix.scaled(150, 150, Qt.AspectRatioMode.KeepAspectRatio)
            self.crewmate.setPixmap(scaled_pix)
            self.crewmate.move(530, 380)
            self.crewmate.raise_()

    def show_menu(self):
        if self.terminal_process:
            self.terminal_process.terminate()
        self.stack.setCurrentIndex(0)
        self.crewmate.raise_()

    def run_terminal_task(self, script_name, use_sudo=True):
        self.stack.setCurrentIndex(1)
        self.crewmate.raise_()
        
        base_dir = os.path.dirname(os.path.abspath(__file__))
        script_path = os.path.normpath(os.path.join(base_dir, "..", "options", script_name))
        
        # Embed XFCE Terminal into the window
        # We use the --hold flag so you can see the results before closing
        cmd = ["xfce4-terminal", f"--parent-id={int(self.terminal_container.winId())}", "--hold", "-e"]
        
        if use_sudo:
            exec_cmd = f"pkexec bash {script_path}"
        else:
            exec_cmd = f"bash {script_path}"
            
        cmd.append(exec_cmd)
        
        self.terminal_process = QProcess(self)
        self.terminal_process.start(cmd[0], cmd[1:])

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = AmogOSGui()
    ex.show()
    sys.exit(app.exec())
