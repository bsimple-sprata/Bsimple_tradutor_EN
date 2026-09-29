# Bsimple UK English Translation Instructions

Whenever you create, translate or modify English text in this project, follow these instructions.

## Official terminology source

Before producing a final translation, consult the complete approved terminology and translation dictionary stored in the official Bsimple Confluence repository:

- Confluence page ID: `772866077`
- Use `Acesso Confluence/Get-ConfluencePage.ps1` or an equivalent authenticated method.
- The official Confluence content is the authoritative source.

## Mandatory complete-dictionary validation

The dictionary must be processed in full. Do not validate the translation using only a selection of keywords, a summary, or terms remembered from previous tasks.

The complete validation must include:

1. Retrieve the entire Confluence page.
2. Preserve and inspect the complete table structure, including:
   - source terms;
   - approved UK English translations;
   - expressions and multi-word phrases;
   - contextual notes;
   - examples;
   - exceptions;
   - prohibited or deprecated alternatives;
   - grammatical or usage instructions.
3. Check every relevant dictionary entry against the content being translated.
4. Apply approved translations consistently throughout the complete text.
5. Give priority to longer expressions and context-specific entries before shorter individual terms.
6. Do not replace a term when the dictionary specifies an exception or a different contextual translation.
7. Identify and report:
   - terms that were replaced;
   - terms found without an approved dictionary entry;
   - ambiguous terms requiring human confirmation;
   - conflicts or duplicate instructions in the dictionary.
8. Perform a second review of the complete translated text against the complete dictionary before presenting the final result.

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
- the approved terms applied;
- unresolved or ambiguous terms;
- any deviations from the approved terminology;
- confirmation that the complete translated content was reviewed.

A translation must not be presented as fully validated unless the complete official dictionary was successfully retrieved and checked.
