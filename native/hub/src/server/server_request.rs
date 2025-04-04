#[macro_export]
macro_rules! listen_server_event {
    ($server:expr, $global_params:expr, $($req:tt)*) => {
        process_server_handlers!(@internal $server, $global_params, $($req)*);
    };
}

#[macro_export]
macro_rules! process_server_handlers {
    (@internal $server:expr, $global_params:expr, ($request:ty, $response:ty) $(, $rest:tt)*) => {
        register_single_handler!($server, $global_params, $request, with_response);
        process_server_handlers!(@internal $server, $global_params $(, $rest)*);
    };
    (@internal $server:expr, $global_params:expr, $request:ty $(, $rest:tt)*) => {
        register_single_handler!($server, $global_params, $request, without_response);
        process_server_handlers!(@internal $server, $global_params $(, $rest)*);
    };
    (@internal $server:expr, $global_params:expr $(,)?) => {};
}

#[macro_export]
macro_rules! register_single_handler {
    ($server:expr, $global_params:expr, $request:ty, $with_response:tt) => {
        paste::paste! {
            let global_params = $global_params.clone();
            $server.register_handler(stringify!($request), move |payload, session| {
                let global_params = global_params.clone();
                async move {
                    let buf = payload.as_slice();
                    let request = match $request::decode(buf) {
                        Ok(req) => req,
                        Err(e) => {
                            error!("Failed to deserialize request: {:?}", e);
                            return ("CrashResponse".to_owned(), CrashResponse {
                                detail: format!("Failed to deserialize request: {:?}", e),
                            }.encode_to_vec());
                        }
                    };

                    let params = request.extract_params(&global_params);
                    match request.handle(params, session, &request).await {
                        Ok(_response) => {
                            handle_server_response!(_response, $with_response)
                        }
                        Err(e) => {
                            error!("Error handling request: {:?}", e);
                            ("CrashResponse".to_owned(), CrashResponse {
                                detail: format!("{:#?}", e),
                            }.encode_to_vec())
                        }
                    }
                }
            }).await;
        }
    };
}

#[macro_export]
macro_rules! handle_server_response {
    ($response:expr, with_response) => {
        if let Some(response) = $response {
            (response.name(), response.encode_to_vec())
        } else {
            ("".to_owned(), Vec::new())
        }
    };
    ($response:expr, without_response) => {
        ("".to_owned(), Vec::new())
    };
}
