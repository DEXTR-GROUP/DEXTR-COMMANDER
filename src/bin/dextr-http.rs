use rmcp::{
    handler::server::wrapper::Parameters,
    schemars, tool, tool_router,
    transport::streamable_http_server::{
        session::local::LocalSessionManager, StreamableHttpServerConfig, StreamableHttpService,
    },
};
use std::process::Command;

#[derive(Debug, serde::Deserialize, schemars::JsonSchema)]
struct ExecuteCommandParams {
    command: String,
}

#[derive(Debug, serde::Deserialize, schemars::JsonSchema)]
struct ReadFileParams {
    path: String,
}

#[derive(Clone)]
struct DextrCommander;

#[tool_router(server_handler)]
impl DextrCommander {
    #[tool(
        name = "execute_command",
        description = "Execute a shell command on the local host."
    )]
    async fn execute_command(
        &self,
        Parameters(ExecuteCommandParams { command }): Parameters<ExecuteCommandParams>,
    ) -> String {
        run_shell_command(&command)
    }

    #[tool(
        name = "read_file",
        description = "Read a UTF-8 text file from the local host."
    )]
    async fn read_file(
        &self,
        Parameters(ReadFileParams { path }): Parameters<ReadFileParams>,
    ) -> String {
        match std::fs::read_to_string(&path) {
            Ok(content) => content,
            Err(error) => format!("File read error: {error}"),
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

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bind_address = "127.0.0.1:8787";

    let config = StreamableHttpServerConfig::default()
        .with_legacy_session_mode(false)
        .with_json_response(true)
        .with_max_request_body_bytes(1024 * 1024);

    let service = StreamableHttpService::new(
        || Ok(DextrCommander),
        LocalSessionManager::default().into(),
        config,
    );

    let router = axum::Router::new().nest_service("/mcp", service);
    let listener = tokio::net::TcpListener::bind(bind_address).await?;

    eprintln!("[DEXTR-COMMANDER] MCP Streamable HTTP: http://{bind_address}/mcp");

    axum::serve(listener, router).await?;
    Ok(())
}
