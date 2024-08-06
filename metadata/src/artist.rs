use lazy_static::lazy_static;
use regex::Regex;

lazy_static! {
    static ref SPLITTERS: Vec<&'static str> = vec![", ", " × ", " ft. ", " feat. " , " & "];
    static ref WHITELIST: Vec<&'static str> = vec![];
    static ref SPLITTERS_REGEX: Regex = {
        let splitters_pattern = SPLITTERS
            .iter()
            .map(|s| regex::escape(s))
            .collect::<Vec<String>>()
            .join("|");
        Regex::new(&splitters_pattern).unwrap()
    };
}

pub fn split_artists(input: &str) -> Vec<String> {
    let parts_with_splitters: Vec<&str> = SPLITTERS_REGEX.split(input).collect();
    let mut parts: Vec<String> = Vec::new();

    for i in 0..parts_with_splitters.len() {
        let part = parts_with_splitters[i].trim();
        if !part.is_empty() {
            parts.push(part.to_string());
        }
        // Add the splitter back if it's not the last part
        if i < parts_with_splitters.len() - 1 {
            let splitter = SPLITTERS_REGEX
                .find(&input[parts_with_splitters[i].len()..])
                .unwrap()
                .as_str();
            parts.push(splitter.to_string());
        }
    }

    let mut i = 0;
    while i < parts.len() {
        if WHITELIST.contains(&parts[i].as_str()) {
            i += 1;
            continue;
        }
        for j in (i + 1)..parts.len() {
            if SPLITTERS.contains(&parts[j].as_str()) {
                continue;
            }
            let combined = parts[i..=j].join("");
            if WHITELIST.contains(&combined.as_str()) {
                parts[i] = combined;
                parts.drain((i + 1)..=j);
                break;
            }
        }
        i += 1;
    }

    parts
        .into_iter()
        .filter(|s| !SPLITTERS.contains(&s.as_str()))
        .collect()
}