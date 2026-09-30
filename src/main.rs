use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::process::Command;
use tokio::io::{self, AsyncBufReadExt, AsyncWriteExt, BufReader};

#[derive(Deserialize, Debug)]
struct JsonRpcRequest {
    #[allow(dead_code)]
    jsonrpc: String,
    id: Option<Value>,
    method: String,
    params: Option<Value>,
}

#[derive(Serialize, Debug)]
struct JsonRpcResponse {
    jsonrpc: &'static str,
    #[serde(skip_serializing_if = "Option::is_none")]
    id: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    result: Option<Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<Value>,
}

#[tokio::main]
async fn main() -> io::Result<()> {
    let stdin = io::stdin();
    let mut stdout = io::stdout();
    let reader = BufReader::new(stdin);
    let mut lines = reader.lines();

    while let Some(line) = lines.next_line().await? {
        if line.trim().is_empty() {
            continue;
        }

        let req: Result<JsonRpcRequest, _> = serde_json::from_str(&line);

        match req {
            Ok(req) => {
                if let Some(resp) = handle_request(req) {
                    let resp_json = serde_json::to_string(&resp).unwrap();
                    stdout.write_all(resp_json.as_bytes()).await?;
                    stdout.write_all(b"\n").await?;
                    stdout.flush().await?;
                }
            }
            Err(e) => {
                eprintln!("[MCP DEBUG] Invalid JSON-RPC request: {e}");
                let response = JsonRpcResponse {
                    jsonrpc: "2.0",
                    id: None,
                    result: None,
                    error: Some(json!({
                        "code": -32700,
                        "message": "Parse error"
                    })),
                };
                let response_json = serde_json::to_string(&response).unwrap();
                stdout.write_all(response_json.as_bytes()).await?;
                stdout.write_all(b"\n").await?;
                stdout.flush().await?;
            }
        }
    }

    Ok(())
}

fn handle_request(req: JsonRpcRequest) -> Option<JsonRpcResponse> {
    match req.method.as_str() {
        "initialize" => Some(JsonRpcResponse {
            jsonrpc: "2.0",
            id: req.id,
            result: Some(json!({
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {
                    "name": "dextr-commander",
                    "version": "0.1.0"
                }
            })),
            error: None,
        }),

        "notifications/initialized" => None,

        "tools/list" => Some(JsonRpcResponse {
            jsonrpc: "2.0",
            id: req.id,
            result: Some(json!({
                "tools": [
                    {
                        "name": "execute_command",
                        "description": "Execute a command in the local system shell",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "command": {
                                    "type": "string",
                                    "description": "Shell command to execute"
                                }
                            },
                            "required": ["command"]
                        }
                    },
                    {
                        "name": "read_file",
                        "description": "Read a local UTF-8 text file",
                        "inputSchema": {
                            "type": "object",
                            "properties": {
                                "path": {
                                    "type": "string",
                                    "description": "Path to the file"
                                }
                            },
                            "required": ["path"]
                        }
                    }
                ]
            })),
            error: None,
        }),

        "tools/call" => {
            let params = req.params.unwrap_or_else(|| json!({}));
            let tool_name = params.get("name").and_then(Value::as_str).unwrap_or("");
            let arguments = params
                .get("arguments")
                .cloned()
                .unwrap_or_else(|| json!({}));

            let result_text = match tool_name {
                "execute_command" => {
                    let command = arguments
                        .get("command")
                        .and_then(Value::as_str)
                        .unwrap_or("");
                    run_shell_command(command)
                }
                "read_file" => {
                    let path = arguments.get("path").and_then(Value::as_str).unwrap_or("");
                    match std::fs::read_to_string(path) {
                        Ok(content) => content,
                        Err(error) => format!("File read error: {error}"),
                    }
                }
                _ => format!("Unknown tool: {tool_name}"),
            };

            Some(JsonRpcResponse {
                jsonrpc: "2.0",
                id: req.id,
                result: Some(json!({
                    "content": [{"type": "text", "text": result_text}]
                })),
                error: None,
            })
        }

        _ => {
            if req.id.is_some() {
                Some(JsonRpcResponse {
                    jsonrpc: "2.0",
                    id: req.id,
                    result: None,
                    error: Some(json!({
                        "code": -32601,
                        "message": "Method not found"
                    })),
                })
            } else {
                None
            }
        }
    }
}

fn run_shell_command(command: &str) -> String {
    #[cfg(target_os = "windows")]
    let output = Command::new("cmd").args(["/C", command]).output();

    #[cfg(not(target_os = "windows"))]
    let output = Command::new("sh").arg("-c").arg(command).output();

    match output {
        Ok(output) => {
            let stdout = String::from_utf8_lossy(&output.stdout);
            let stderr = String::from_utf8_lossy(&output.stderr);

            if stderr.is_empty() {
                stdout.to_string()
            } else {
                format!("STDOUT:\n{stdout}\nSTDERR:\n{stderr}")
            }
        }
        Err(error) => format!("Command execution error: {error}"),
    }
}
