import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ScrollView {
    id: settingsScroll
    anchors.fill: parent

    property int refreshTrigger: 0

    Connections {
        target: backend

        function onSettingsChanged() {
            refreshTrigger++
        }
    }
    

    ColumnLayout {
        id: mainLayout
        width: parent.width
        spacing: 16
        
        // padding: 12

        // ------------------------
        // User Settings Section
        // ------------------------
        GroupBox {
            title: "User Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                RowLayout {
                    spacing: 6
                    Label { text: "Name:"; Layout.preferredWidth: 240 }
                    TextField {
                        text: { 
                            refreshTrigger
                            return backend.getSettings("user_settings.name")
                        }
                        onTextChanged: backend.setSettings("user_settings.name", text)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 6
                    Label { text: "Timezone:"; Layout.preferredWidth: 240 }
                    TextField {
                        text: { 
                            refreshTrigger
                            return backend.getSettings("user_settings.timezone")
                        }
                        onTextChanged: backend.setSettings("user_settings.timezone", text)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 6
                    Label { text: "Primary Language:"; Layout.preferredWidth: 240 }
                    TextField {
                        text: { 
                            refreshTrigger
                            return backend.getSettings("user_settings.primary_language")
                        }
                        onTextChanged: backend.setSettings("user_settings.primary_language", text)
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // ------------------------
        // Model Settings Section
        // ------------------------
        GroupBox {
            title: "Model Settings - Instruct (Chat)"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                // CheckBox {
                //     text: "Enabled"
                //     checked: { 
                    //     refreshTrigger
                    //     return backend.getSettings("model_settings.instruct.enabled")
                    // }
                //     onToggled: backend.setSettings("model_settings.instruct.enabled", checked)
                // }

                RowLayout {
                    spacing: 70
                    Label { text: "Max Tokens:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.max_tokens")
                        }
                        from: 128; to: 8192
                        onValueChanged: backend.setSettings("model_settings.instruct.max_tokens", value)
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Max Context:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.max_context")
                        }
                        from: 512; to: 16384
                        onValueChanged: backend.setSettings("model_settings.instruct.max_context", value)
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Temperature:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(instructTemp.value).toFixed(2) } }
                    Slider {
                        id: instructTemp
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.temperature")
                        }
                        onMoved: backend.setSettings("model_settings.instruct.temperature", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Top K:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(instructTopK.value) } }
                    Slider {
                        id: instructTopK
                        from: 0; to: 100; stepSize: 1
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.top_k")
                        }
                        onMoved: backend.setSettings("model_settings.instruct.top_k", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Top P:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(instructTopP.value).toFixed(2) } }
                    Slider {
                        id: instructTopP
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.top_p")
                        }
                        onMoved: backend.setSettings("model_settings.instruct.top_p", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Min P:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(instructMinP.value).toFixed(2) } }
                    Slider {
                        id: instructMinP
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.min_p")
                        }
                        onMoved: backend.setSettings("model_settings.instruct.min_p", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Repetition Penalty:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(instructRepPenalty.value).toFixed(1) } }
                    Slider {
                        id: instructRepPenalty
                        from: 0; to: 5; stepSize: 0.1
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.repetition_penalty")
                        }
                        onMoved: backend.setSettings("model_settings.instruct.repetition_penalty", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Mirostat Mode:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.instruct.mirostat_mode")
                        }
                        from: 0; to: 3;
                        onValueChanged: backend.setSettings("model_settings.instruct.mirostat_mode", value)
                    }
                }
            }
        }

        GroupBox {
            title: "Model Settings - Thinking"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Enabled"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("model_settings.thinking.enabled")
                    }
                    onToggled: backend.setSettings("model_settings.thinking.enabled", checked)
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Max Tokens:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.max_tokens")
                        }
                        from: 1; to: 8192
                        onValueChanged: backend.setSettings("model_settings.thinking.max_tokens", value)
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Max Context:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.max_context")
                        }
                        from: 512; to: 16384
                        onValueChanged: backend.setSettings("model_settings.thinking.max_context", value)
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Temperature:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(thinkingTemp.value).toFixed(2) }}
                    Slider {
                        id: thinkingTemp
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.temperature")
                        }
                        onMoved: backend.setSettings("model_settings.thinking.temperature", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Top K:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(thinkingTopK.value) }}
                    Slider {
                        id: thinkingTopK
                        from: 0; to: 100; stepSize: 1
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.top_k")
                        }
                        onMoved: backend.setSettings("model_settings.thinking.top_k", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Top P:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(thinkingTopP.value).toFixed(2) } }
                    Slider {
                        id: thinkingTopP
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.top_p")
                        }
                        onMoved: backend.setSettings("model_settings.thinking.top_p", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Min P:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(thinkingMinP.value).toFixed(2) } }
                    Slider {
                        id: thinkingMinP
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.min_p")
                        }
                        onMoved: backend.setSettings("model_settings.thinking.min_p", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Repetition Penalty:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(thinkingRepPenalty.value).toFixed(1) } }
                    Slider {
                        id: thinkingRepPenalty
                        from: 0; to: 5; stepSize: 0.1
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.repetition_penalty")
                        }
                        onMoved: backend.setSettings("model_settings.thinking.repetition_penalty", value)
                        Layout.fillWidth: true
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Mirostat Mode:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("model_settings.thinking.mirostat_mode")
                        }
                        from: 0; to: 3;
                        onValueChanged: backend.setSettings("model_settings.thinking.mirostat_mode", value)
                    }
                }
            }
        }

        // ------------------------
        // Generate Settings
        // ------------------------
        GroupBox {
            title: "Generation Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Streamer Enabled"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("generate_settings.streamer")
                    }
                    onToggled: backend.setSettings("generate_settings.streamer", checked)
                }

                CheckBox {
                    text: "Use Emojis"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("generate_settings.use_emojis")
                    }
                    onToggled: backend.setSettings("generate_settings.use_emojis", checked)
                }
            }
        }

        // ------------------------
        // RAG Settings
        // ------------------------
        GroupBox {
            title: "RAG Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Enabled"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("rag_settings.enabled")
                    }
                    onToggled: backend.setSettings("rag_settings.enabled", checked)
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Weight:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(ragWeight.value).toFixed(2) } }
                    Slider {
                        id: ragWeight
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("rag_settings.weight")
                        }
                        onMoved: backend.setSettings("rag_settings.weight", value)
                        Layout.fillWidth: true
                    }
                }

                CheckBox {
                    text: "Rerank"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("rag_settings.rerank")
                    }
                    onToggled: backend.setSettings("rag_settings.rerank", checked)
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Min Score:"; Layout.preferredWidth: 240 }
                    Item { width: 50; height: 30; Text { wrapMode: Text.Wrap; text: Number(ragMinScore.value).toFixed(2) } }
                    Slider {
                        id: ragMinScore
                        from: 0; to: 1; stepSize: 0.01
                        value: { 
                            refreshTrigger
                            return backend.getSettings("rag_settings.min_score")
                        }
                        onMoved: backend.setSettings("rag_settings.min_score", value)
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // ------------------------
        // Embedding Settings
        // ------------------------
        GroupBox {
            title: "Embedding Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Enabled"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("embedding_settings.enabled")
                    }
                    onToggled: backend.setSettings("embedding_settings.enabled", checked)
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Top Max Embedding Scans:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("embedding_settings.top_max_embedding_scan")
                        }
                        from: 1; to: 10;
                        onValueChanged: backend.setSettings("embedding_settings.top_max_embedding_scan", value)
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Chunk Size:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("embedding_settings.chunk_size")
                        }
                        from: 1; to: 2048;
                        onValueChanged: backend.setSettings("embedding_settings.chunk_size", value)
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Overlap:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("embedding_settings.overlap")
                        }
                        from: 1; to: 100;
                        onValueChanged: backend.setSettings("embedding_settings.overlap", value)
                    }
                }
            }
        }

        // ------------------------
        // Max Tasks
        // ------------------------
        GroupBox {
            title: "Max Tasks"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                RowLayout {
                    spacing: 70
                    
                    Label { text: "AI Tasks:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("max_tasks.ai_tasks")
                        }
                        from: 1; to: 3;
                        onValueChanged: backend.setSettings("max_tasks.ai_tasks", value)
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "System Tasks:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("max_tasks.system_tasks")
                        }
                        from: 1; to: 3;
                        onValueChanged: backend.setSettings("max_tasks.system_tasks", value)
                    }
                }
                // RowLayout {
                //     spacing: 70
                //     Label { text: "Overlap"; Layout.preferredWidth: 240 }
                //     SpinBox {
                //         value: { 
                        //     refreshTrigger
                        //     return backend.getSettings("embedding_settings.overlap")
                        // }
                //         from: 1; to: 100;
                //         onValueChanged: backend.setSettings("embedding_settings.overlap", value)
                //     }
                // }
            }
        }

        // ------------------------
        // Summary Settings
        // ------------------------
        GroupBox {
            title: "Summary Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                RowLayout {
                    spacing: 70
                    Label { text: "Summarize Every (?) Messages:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("summary_settings.max_messages")
                        }
                        from: 3; to: 25;
                        onValueChanged: backend.setSettings("summary_settings.max_messages", value)
                    }
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Keep Most Recent (?) Messages Fresh:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("summary_settings.keep_fresh")
                        }
                        from: 1; to: 3;
                        onValueChanged: backend.setSettings("summary_settings.keep_fresh", value)
                    }
                }

                RowLayout {
                    spacing: 35
                    Label { text: "Summary (Tokens) Threshold:"; Layout.preferredWidth: 240 }
                    Item { height: 50; width: 20; Text { wrapMode: Text.Wrap ; text: Number(summaryThreshold.value); anchors.centerIn: parent} }
                    Slider {
                        id: summaryThreshold
                        value: { 
                            refreshTrigger
                            return backend.getSettings("summary_settings.summary_token_threshold")
                        }
                        from: 50; to: 5000; stepSize: 1;
                        onMoved: backend.setSettings("summary_settings.summary_token_threshold", value)
                    }
                }
            }
        }

        // ------------------------
        // Tool Settings
        // ------------------------
        GroupBox {
            id: toolSettings
            title: "Tool Settings - Search Files(InComplete)"
            Layout.fillWidth: true

            property var restrictedPaths: backend.getSettings("tool_settings.search_files.restricted_paths") || []

            function addRestrictedPath(path) {
                if(!restrictedPaths.includes(path)) {
                    var newList = restrictedPaths.slice()
                    newList.push(path)
                    restrictedPaths = newList

                    backend.setSettings("tool_settings.search_files.restricted_paths", restrictedPaths)
                }
            }

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Enabled"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("tool_settings.search_files.enabled")
                    }
                    onToggled: backend.setSettings("tool_settings.search_files.enabled", checked)
                }

                RowLayout {
                    spacing: 70
                    Label { text: "Max Results:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("tool_settings.search_files.max_results")
                        }
                        from: 3; to: 75;
                        onValueChanged: backend.setSettings("tool_settings.search_files.max_results", value)
                    }
                }
                // SEARCH PATH
                RowLayout {
                    spacing: 6
                    Label { text: "Search Path:"; Layout.preferredWidth: 240 }

                    TextField {
                        id: searchPathField
                        text: { 
                            refreshTrigger
                            return backend.getSettings("tool_settings.search_files.search_path")
                        }
                        readOnly: true
                        Layout.fillWidth: true
                    }
                    
                    Button {
                        text: "Browse"
                        onClicked: searchFilesDialog.open()
                    }
                }
                FolderDialog {
                    id: searchFilesDialog
                    onAccepted: {
                        searchPathField.text = selectedFolder.toString().replace("file:///", "")
                        backend.setSettings("tool_settings.search_files.search_path", searchPathField.text)
                    }
                }
                // RESTRICTED PATHES
                RowLayout {
                    spacing: 6
                    Label { text: "Restricted Paths"; Layout.preferredWidth: 240 }

                    Button {
                        text: "Add Folder"
                        onClicked: restrictedPathsDialog.open()
                    }
                }

                Repeater {
                    model: toolSettings.restrictedPaths

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: modelData
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Button {
                            text: "✕"
                            onClicked: {
                                var newList = toolSettings.restrictedPaths.slice()
                                newList.splice(index, 1)
                                toolSettings.restrictedPaths = newList

                                backend.setSettings("tool_settings.search_files.restricted_paths", toolSettings.restrictedPaths)
                            }
                        }
                    }
                }

                FolderDialog {
                    id: restrictedPathsDialog

                    onAccepted: {
                        var path = selectedFolder.toString().replace("file:///", "")
                        toolSettings.addRestrictedPath(path)
                    }
                }
                RowLayout {
                    spacing: 70
                    Label { text: "Max File Size (MB):"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("tool_settings.search_files.max_file_size_mb")
                        }
                        from: 1; to: 100;
                        onValueChanged: backend.setSettings("tool_settings.search_files.max_file_size_mb", value)
                    }
                }

                CheckBox {
                    text: "Can Search Sub Directories"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("tool_settings.search_files.can_search_sub_directories")
                    }
                    onToggled: backend.setSettings("tool_settings.search_files.can_search_sub_directories", checked)
                }
            }
        }

        GroupBox {
            title: "Tool Settings - Web Search"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Enabled"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("tool_settings.web_search.enabled")
                    }
                    onToggled: backend.setSettings("tool_settings.web_search.enabled", checked)
                }

                CheckBox {
                    text: "Live View"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("tool_settings.web_search.live_view")
                    }
                    onToggled: backend.setSettings("tool_settings.web_search.live_view", checked)
                }
            }
        }

        // ------------------------
        // UI Settings
        // ------------------------
        GroupBox {
            title: "UI Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                RowLayout {
                    spacing: 6
                    Label { text: "Theme:"; Layout.preferredWidth: 240 }
                    TextField {
                        text: { 
                            refreshTrigger
                            return backend.getSettings("ui.theme")
                        }
                        onTextChanged: backend.setSettings("ui.theme", text)
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    spacing: 70
                    Label { text: "Font Size:"; Layout.preferredWidth: 240 }
                    SpinBox {
                        value: { 
                            refreshTrigger
                            return backend.getSettings("ui.font-size")
                        }
                        from: 5; to: 25;
                        onValueChanged: backend.setSettings("ui.font-size", value)
                    }
                }
                CheckBox {
                    text: "Markdown"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("ui.markdown")
                    }
                    onToggled: backend.setSettings("ui.markdown", checked)
                }
            }
        }

        // ------------------------
        // Debug Settings
        // ------------------------
        GroupBox {
            title: "Debug Settings"
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                width: parent.width

                CheckBox {
                    text: "Error Popups"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("debug.error_popups")
                    }
                    onToggled: backend.setSettings("debug.error_popups", checked)
                }
                CheckBox {
                    text: "Log Phase"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("debug.log_phases")
                    }
                    onToggled: backend.setSettings("debug.log_phases", checked)
                }
                CheckBox {
                    text: "Log Tokens"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("debug.log_tokens")
                    }
                    onToggled: backend.setSettings("debug.log_tokens", checked)
                }
                CheckBox {
                    text: "Log RAG"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("debug.log_rag")
                    }
                    onToggled: backend.setSettings("debug.log_rag", checked)
                }
                CheckBox {
                    text: "Log Tools"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("debug.log_tools")
                    }
                    onToggled: backend.setSettings("debug.log_tools", checked)
                }
                CheckBox {
                    text: "Save Logs to File"
                    checked: { 
                        refreshTrigger
                        return backend.getSettings("debug.save_log_to_file")
                    }
                    onToggled: backend.setSettings("debug.save_log_to_file", checked)
                }
                // LOG FILE LOCATION
                RowLayout {
                    spacing: 6
                    Label { text: "Log File Location"; Layout.preferredWidth: 240 }

                    TextField {
                        id: logFileField
                        text: { 
                            refreshTrigger
                            return backend.getSettings("debug.log_file_location")
                        }
                        readOnly: true
                        Layout.fillWidth: true
                    }

                    Button {
                        text: "Browse"
                        onClicked: logFileDialog.open()
                    }
                }

                FileDialog {
                    id: logFileDialog
                    fileMode: FileDialog.SaveFile
                    nameFilters: ["Log files (*.log)", "Text files (*.txt)"]

                    onAccepted: {
                        logFileField.text = selectedFile.toString().replace("file:///", "")
                        backend.setSettings("debug.log_file_location", logFileField.text)
                    }
                }
            }
        }

        // ------------------------
        // Load Default Button
        // ------------------------
        Button {
            id: loadDefaultButton
            text: "Load Default"
            Layout.alignment: Qt.AlignHCenter
            enabled: false

            Connections {
                target: backend
                function onDefaultSettings(state) {
                    loadDefaultButton.enabled = state
                }
            }

            onClicked: backend.setToDefault()
        }

        // ------------------------
        // Save Button
        // ------------------------
        Button {
            id: saveButton
            text: "Save Settings"
            Layout.alignment: Qt.AlignHCenter
            enabled: false

            Connections {
                target: backend
                function onUnsavedChanges(state) {
                    saveButton.enabled = state
                }
            }

            onClicked: backend.saveSettings()
        }
    }
}