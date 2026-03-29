permissionset 50600 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "BeOCR Setup" = RIMD,
        tabledata "Document Header" = RIMD,
        tabledata "Document Line" = RIMD,
        table "BeOCR Setup" = X,
        table "Document Header" = X,
        table "Document Line" = X,
        codeunit "API Rest Helper" = X,
        codeunit "OCR Integration" = X,
        codeunit "Syncronice Be OCR" = X,
        page "BeOCR Config Card" = X,
        page "Document Header Card" = X,
        page "Document Header List" = X,
        page "Document Line SubList" = X,
        page "PDF Preview" = X,
        tabledata "OCR Log" = RIMD,
        table "OCR Log" = X;
}