{
    id,fullDatabaseId,
    project{ id, number, title, url},
    content{{content}},
    fieldValues(first: 100){
        nodes{{fieldValuesNodes}}
    }
}