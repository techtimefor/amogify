import sys
import os
from PyQt6.QtWidgets import (QApplication, QWidget, QPushButton, QVBoxLayout, 
                             QLabel, QHBoxLayout, QPlainTextEdit, QStackedWidget)
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
            #back_btn { background-color: #333; margin-top: 10px; }
            QPlainTextEdit {
                background-color: rgba(0, 0, 0, 180);
                border: 1px solid #ff4444; border-radius: 8px; color: #00ff00;
                font-family: 'Monospace'; font-size: 12px;
            }
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
        # Needs Sudo
        btn_amog.clicked.connect(lambda: self.start_task("install.sh", "Installing AmogOS...", sudo=True))
        
        btn_undo = QPushButton("UN-AMOGIFY (UNDO)")
        # Needs Sudo
        btn_undo.clicked.connect(lambda: self.start_task("uninstall.sh", "Ejecting Imposter...", sudo=True))
        
        h_buttons = QHBoxLayout()
        btn_support = QPushButton("Support")
        # No Sudo
        btn_support.clicked.connect(lambda: self.start_task("support.sh", "Emergency Meeting...", sudo=False))
        btn_about = QPushButton("About")
        # No Sudo
        btn_about.clicked.connect(lambda: self.start_task("about.sh", "System Info...", sudo=False))
        
        h_buttons.addWidget(btn_support)
        h_buttons.addWidget(btn_about)

        menu_layout.addWidget(title)
        menu_layout.addWidget(btn_amog)
        menu_layout.addWidget(btn_undo)
        menu_layout.addLayout(h_buttons)

        # --- SCREEN 2: TERMINAL ---
        self.terminal_widget = QWidget()
        term_layout = QVBoxLayout(self.terminal_widget)
        self.term_title = QLabel("Executing...")
        self.term_title.setObjectName("title")
        self.term_title.setStyleSheet("font-size: 24px;")
        term_layout.addWidget(self.term_title)

        self.terminal_output = QPlainTextEdit()
        self.terminal_output.setReadOnly(True)
        term_layout.addWidget(self.terminal_output)

        self.btn_back = QPushButton("BACK TO MENU")
        self.btn_back.setObjectName("back_btn")
        self.btn_back.setVisible(False)
        self.btn_back.clicked.connect(self.show_menu)
        term_layout.addWidget(self.btn_back)

        self.stack.addWidget(self.menu_widget)
        self.stack.addWidget(self.terminal_widget)
        self.master_layout.addWidget(self.stack)

        # 3. CREWMATE OVERLAY (Fixed pathing and layering)
        self.crewmate = QLabel(self)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        # Using normpath to handle the '..' properly
        asset_path = os.path.normpath(os.path.join(script_dir, "assets", "amogus.webp"))
        
        if os.path.exists(asset_path):
            pix = QPixmap(asset_path)
            if not pix.isNull():
                scaled_pix = pix.scaled(180, 180, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation)
                self.crewmate.setPixmap(scaled_pix)
                self.crewmate.setFixedSize(scaled_pix.size())
                self.crewmate.move(510, 370) # Static position over the bottom right
                self.crewmate.raise_() 
            else:
                print("Warning: Failed to load image. Is libqt6imageformats6 installed?")
        else:
            print(f"Warning: Asset not found at {asset_path}")

    def show_menu(self):
        self.stack.setCurrentIndex(0)
        self.btn_back.setVisible(False)
        self.crewmate.raise_() # Ensure he stays on top

    def start_task(self, script_name, title_text, sudo=False):
        self.terminal_output.clear()
        self.term_title.setText(title_text)
        self.stack.setCurrentIndex(1)
        self.btn_back.setVisible(False)
        self.crewmate.raise_()
        
        self.process = QProcess()
        self.process.setProcessChannelMode(QProcess.ProcessChannelMode.MergedChannels)
        self.process.readyReadStandardOutput.connect(self.handle_output)
        self.process.finished.connect(self.task_finished)
        
        base_dir = os.path.dirname(os.path.abspath(__file__))
        script_path = os.path.normpath(os.path.join(base_dir, "..", "options", script_name))
        
        if os.path.exists(script_path):
            os.chmod(script_path, 0o755)
            if sudo:
                # Triggers password UI
                self.process.start("pkexec", ["bash", script_path])
            else:
                # Runs as current user, no password popup
                self.process.start("bash", [script_path])
        else:
            self.terminal_output.appendPlainText(f"Error: {script_name} not found at {script_path}")
            self.btn_back.setVisible(True)

    def handle_output(self):
        data = self.process.readAllStandardOutput().data().decode()
        self.terminal_output.insertPlainText(data)
        self.terminal_output.verticalScrollBar().setValue(self.terminal_output.verticalScrollBar().maximum())

    def task_finished(self, exit_code, exit_status):
        if exit_code != 0:
            self.terminal_output.appendPlainText(f"\n[!] ERROR: Task failed or cancelled (Code: {exit_code})")
        else:
            self.terminal_output.appendPlainText("\n--- MISSION ACCOMPLISHED ---")
        
        self.btn_back.setVisible(True)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = AmogOSGui()
    ex.show()
    sys.exit(app.exec())
