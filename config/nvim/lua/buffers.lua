-- ==========================================================
-- buffers.lua — закрытие буферов без «пустых вкладок»
-- Пустой буфер-заглушка один и не попадает в tabline.
-- ==========================================================

local M = {}

local function is_placeholder(buf)
    return vim.api.nvim_buf_is_valid(buf)
        and vim.api.nvim_buf_get_name(buf) == ""
        and vim.bo[buf].buftype == ""
        and not vim.bo[buf].modified
end

M.is_placeholder = is_placeholder

-- Найти существующую заглушку или создать одну (не listed)
function M.placeholder(exclude)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= exclude and is_placeholder(buf) then
            return buf
        end
    end

    local buf = vim.api.nvim_create_buf(false, false)
    vim.bo[buf].bufhidden = "hide"
    return buf
end

-- Удалить лишние заглушки, которые не показаны ни в одном окне
function M.prune(keep)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= keep and is_placeholder(buf) and vim.fn.bufwinid(buf) == -1 then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
end

-- Показать буфер в окне; пустую заглушку убрать из tabline
function M.show(win, buf)
    if is_placeholder(buf) then
        vim.bo[buf].buflisted = false
    end
    vim.api.nvim_win_set_buf(win, buf)
end

-- Закрыть текущий буфер, сохранив окно
function M.close_current()
    local buf = vim.api.nvim_get_current_buf()

    if vim.bo[buf].buftype ~= "" or is_placeholder(buf) then
        return
    end

    if vim.bo[buf].modified then
        vim.notify("Буфер изменён: сохрани его или выполни :bd!", vim.log.levels.WARN)
        return
    end

    local target = vim.fn.bufnr("#")
    if
        target < 1
        or target == buf
        or vim.fn.bufexists(target) ~= 1
        or vim.fn.buflisted(target) ~= 1
    then
        target = M.placeholder(buf)
    end

    M.show(0, target)
    vim.api.nvim_buf_delete(buf, { force = true })
    M.prune(target)
end

-- Пустой неотредактированный буфер не должен висеть отдельной вкладкой:
-- Vim создаёт такие после :bd.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    callback = function(args)
        if is_placeholder(args.buf) and vim.bo[args.buf].buflisted then
            vim.bo[args.buf].buflisted = false
        end
    end,
})

-- Как только в пустом буфере появились изменения — показываем его во вкладках
vim.api.nvim_create_autocmd("BufModifiedSet", {
    callback = function(args)
        local buf = args.buf
        if
            vim.bo[buf].buftype == ""
            and vim.api.nvim_buf_get_name(buf) == ""
            and vim.bo[buf].modified
        then
            vim.bo[buf].buflisted = true
        end
    end,
})

return M
