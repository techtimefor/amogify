import sys
import os
from PyQt6.QtWidgets import (QApplication, QWidget, QPushButton, QVBoxLayout, 
                             QLabel, QHBoxLayout)
from PyQt6.QtCore import Qt, QProcess
from PyQt6.QtGui import QPixmap, QLinearGradient, QPalette, QBrush, QColor

class AmogOSGui(QWidget):
    def __init__(self):
        super().__init__()
        self.process = None
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Amogify')
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
            QLabel#title { font-size: 50px; font-weight: 900; color: white; margin-bottom: 0px; }
            QLabel#subtitle { font-size: 18px; color: #ff4444; font-weight: bold; margin-top: 0px; margin-bottom: 20px; }
        """)

        self.master_layout = QVBoxLayout(self)
        
        # --- MENU SCREEN ---
        self.menu_widget = QWidget()
        menu_layout = QVBoxLayout(self.menu_widget)
        menu_layout.setContentsMargins(50, 40, 50, 50)
        
        title = QLabel("Amogify")
        title.setObjectName("title")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        subtitle = QLabel("The most suspicious OS installer")
        subtitle.setObjectName("subtitle")
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        
        btn_amog = QPushButton("AMOGIFY SYSTEM")
        btn_amog.setObjectName("amog_btn")
        btn_amog.clicked.connect(lambda: self.run_task("install.sh"))
        
        btn_undo = QPushButton("UN-AMOGIFY (UNDO)")
        btn_undo.clicked.connect(lambda: self.run_task("uninstall.sh"))
        
        h_buttons = QHBoxLayout()
        btn_support = QPushButton("Support")
        btn_support.clicked.connect(lambda: self.run_task("support.sh"))
        btn_about = QPushButton("About")
        btn_about.clicked.connect(lambda: self.run_task("about.sh"))
        
        h_buttons.addWidget(btn_support)
        h_buttons.addWidget(btn_about)

        menu_layout.addWidget(title)
        menu_layout.addWidget(subtitle)
        menu_layout.addWidget(btn_amog)
        menu_layout.addWidget(btn_undo)
        menu_layout.addLayout(h_buttons)

        self.master_layout.addWidget(self.menu_widget)

        # 3. CREWMATE OVERLAY
        self.crewmate = QLabel(self)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        # Path adjustment for asset location
        asset_path = os.path.normpath(os.path.join(script_dir, "assets", "amogus.webp"))
        
        if os.path.exists(asset_path):
            pix = QPixmap(asset_path)
            scaled_pix = pix.scaled(180, 180, Qt.AspectRatioMode.KeepAspectRatio)
            self.crewmate.setPixmap(scaled_pix)
            self.crewmate.setFixedSize(scaled_pix.size())
            self.crewmate.move(500, 350)
            self.crewmate.raise_()

    def run_task(self, script_name):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        # Assuming gui.py is in 'scripts' and install.sh is in 'options'
        script_path = os.path.normpath(os.path.join(base_dir, "..", "options", script_name))
        
        if not os.path.exists(script_path):
            print(f"Error: {script_path} not found")
            return

        # Ensure script is executable
        os.chmod(script_path, 0o755)

        # Launching terminal as the current user. 
        # The bash script itself will handle 'sudo' prompts inside the terminal window.
        self.process = QProcess(self)
        cmd = ["xfce4-terminal", "--title", f"AmogOS - {script_name}", "--hold", "-e", f"bash {script_path}"]
        self.process.start(cmd[0], cmd[1:])

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = AmogOSGui()
    ex.show()
    sys.exit(app.exec())
