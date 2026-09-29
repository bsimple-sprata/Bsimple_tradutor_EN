# Bsimple UK English Translation Instructions

Whenever you create, translate or modify English text in this project, follow these instructions.

## Official terminology source

Before producing a final translation, consult the complete approved terminology and translation dictionary stored in the official Bsimple Confluence repository:

- Confluence page ID: `772866077`
- Use `Acesso Confluence/Get-ConfluencePage.ps1` or an equivalent authenticated method.
- The official Confluence content is the authoritative source.
- The Confluence page takes precedence over prior memory, any local glossary, and general UK English usage.

## Mandatory complete-dictionary validation

The dictionary must be processed in full. Do not validate the translation using only a selection of keywords, a summary, or terms remembered from previous tasks.

Validation covers all content, not only the main text or prominent terms. Review every heading, paragraph, list item, table cell, UI label, placeholder and code comment, while preserving non-linguistic content as required below.

## Operational validation workflow

Complete these steps in order:

1. Retrieve the entire Confluence page using an authenticated method.
2. Preserve and inspect the complete dictionary and table structure, including:
   - source terms;
   - approved UK English translations;
   - expressions and multi-word phrases;
   - contextual notes;
   - examples;
   - exceptions;
   - prohibited or deprecated alternatives;
   - grammatical or usage instructions.
3. Compare every part of the content with every relevant dictionary entry.
4. Resolve longer expressions and context-specific entries before shorter individual terms, respecting every exception and contextual translation in the dictionary.
5. Mark any term without an approved dictionary entry as `pending review` and request human confirmation. Do not invent translations for terms not in the Confluence dictionary.
6. Apply all approved translations consistently throughout the complete content.
7. Perform a second review of the complete translated content against the complete dictionary.
8. Generate the required validation report, including every terminology change and every unresolved issue.
9. Mark the translation as validated only after all preceding steps are complete. A translation with any term still marked `pending review` must not be presented as fully validated.

## Confluence access failure

If the complete Confluence page cannot be retrieved, do not describe the translation as validated or approved.

Instead:

1. Stop the final translation-validation step.
2. Tell the user that authenticated read access to Confluence is required.
3. Request a valid read-only Confluence connection or API token.
4. Only proceed with a provisional translation if the user explicitly requests it.
5. Clearly label any provisional result as not validated against the official dictionary.

## Content preservation

During translation, preserve all non-linguistic content exactly unless the user explicitly requests otherwise, including:

- Markdown and HTML structure;
- headings, lists and tables;
- placeholders and variables;
- URLs and links;
- IDs and field names;
- code blocks;
- file paths;
- product names and proper names;
- formatting markers;
- XML or JSON syntax.

Do not translate code, variables, placeholders, identifiers or URLs.

## UK English requirements

Use UK English spelling, grammar and terminology. Do not use US English alternatives when an approved Bsimple term or UK English equivalent exists.

## Required validation report

For each completed translation, provide a concise validation report containing:

- whether the complete Confluence dictionary was successfully retrieved;
- the Confluence page ID used;
- the number or scope of dictionary entries checked, where available;
- a terminology change comparison listing every change, with the original term, the approved term from Confluence, and its context or location in the content;
- terms not found in the dictionary, each marked `pending review`;
- ambiguous terms requiring human confirmation;
- conflicts or duplicate instructions in the dictionary;
- any deviations from the approved terminology;
- confirmation that the complete translated content was reviewed.

A translation must not be presented as fully validated unless the complete official dictionary was successfully retrieved and checked.

## If required to write the translation onto Azure DevOps item: 
- the translated text should be inserted in field "BS Description EN" of the identified item.
