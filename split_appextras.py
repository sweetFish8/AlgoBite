import os
import re

source_path = "AlgoBite/AppExtras.swift"
output_dir = "AlgoBite/Extras"

os.makedirs(output_dir, exist_ok=True)

with open(source_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Common imports to add at the top of each new file
base_imports = ["import SwiftUI\n", "import Charts\n\n"]

# Mapping of MARK names (regex) to output filenames
markers = [
    (r"Shared UserDefaults", "AppDefaults.swift"),
    (r"Sweet Illustrations", "Icons.swift"),
    (r"Settings Screen", "SettingsView.swift"),
    (r"Share Sheet", "ShareSheet.swift"),
    (r"Onboarding", "OnboardingView.swift"),
    (r"Achievements Screen", "AchievementsView.swift"),
    (r"Topic Illustration", "TopicIllustration.swift"),
    (r"Haptics", "Haptics.swift"),
    (r"Stats Store", "StatsStore.swift"),
    (r"Badges", "Badges.swift", True), # Skip "Badges Card" as it is handled separately later
    (r"Hint Store", "HintStore.swift"),
    (r"Notifications", "AppNotifications.swift"),
    (r"Reorder Quizzes", "ReorderQuizData.swift", True), # Skip "Reorder Quiz List"
    (r"Stats Card", "StatsCard.swift"),
    (r"Badges Card", "BadgesCard.swift"),
    (r"Reorder Quiz List", "ReorderQuizList.swift"),
    (r"Review Mode", "ReviewMode.swift")
]

current_file = "AppDefaults.swift"
file_contents = {current_file: []}

# Find starting lines for each section
for line in lines:
    if line.strip().startswith("// MARK: - "):
        marker_name = line.strip().replace("// MARK: - ", "").strip()
        
        # Match marker to filename
        found = False
        for m in markers:
            # Simple match checking if the regex string is in the marker name
            # Handle special skips for overlapping names
            if re.search(m[0], marker_name):
                # Special skip condition for Badges vs Badges Card
                if len(m) > 2 and m[2] == True:
                    if "Card" in marker_name or "List" in marker_name:
                        continue # Skip to the correct one
                current_file = m[1]
                if current_file not in file_contents:
                    file_contents[current_file] = []
                found = True
                break
    
    # Append line to current file
    if current_file in file_contents:
        file_contents[current_file].append(line)

created_files = []

# Write files
for filename, content_lines in file_contents.items():
    if not content_lines: continue
    
    out_path = os.path.join(output_dir, filename)
    with open(out_path, "w", encoding="utf-8") as f:
        # Check if imports already exist in the chunk
        has_swiftui = any("import SwiftUI" in l for l in content_lines[:20])
        if not has_swiftui:
            f.writelines(base_imports)
        f.writelines(content_lines)
    
    created_files.append(filename)

print("Split completed successfully into the following files:")
for f in created_files:
    print(f)
