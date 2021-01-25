function! FormatEmailRead()
	set textwidth=79
	" Remove unnecessary fields
	silent g/\v^%(Cc|Bcc|Reply-To):\s*$/d
	" Wrap lines that are on their own to 79 chars
	silent g/\v^(%(\> *)*)$\n\zs^\1.+$\ze\n^\1$/norm! gqj
	normal gg
endfunction

function! FormatEmailWrite()
	set textwidth=79
	" Emails that you reply to contain > quoting of various levels
	" All the regexes here use very-magic
	let indent_specifier       = '%(\> *)*'
	" Don't join lines that start with this header
	let header_start_specifier = '^'.indent_specifier.'\s*[-_]+.*\n'
	" Don't want to join intentionally split things, e.g.
	" > Many Thanks,
	" > John Doe
	" should not become
	" > Many Thanks, John Doe
	" so for now I will assume anything >60 chars can be split. Let's hope
	" there are no >20 character words in the message!

	" Just accept it, my regex skills are glorious
	let g:paragraph_specifier  =
		\ '\v^('.indent_specifier.')\s*$\n%('.header_start_specifier.')@!'
		\.'\zs%(^\1\s*[^>].{60,}$\ze\n)+%(^\1\s*[^>].*$\ze\n)%(^\1\s*$)+'
	" Wherever we match a paragraph, replace any whitespace, the newline, and
	" the indent specifier, with a single space
	while search(g:paragraph_specifier) != 0
		execute 's/\v^'.indent_specifier.'\s*[^ ].*\zs\n^'.indent_specifier.'/ /'
	endwhile
endfunction

augroup EmailFormatting
	" Someone tell me how to make this neater, I can't figure it out
	autocmd! BufWritePre *.eml            call FormatEmailWrite()
	autocmd! BufReadPost *.eml            call FormatEmailRead()
	autocmd! BufWritePre /tmp/mutt*       call FormatEmailWrite()
	autocmd! BufReadPost /tmp/mutt*       call FormatEmailRead()
	autocmd! BufWritePre /tmp/neomutt*    call FormatEmailWrite()
	autocmd! BufReadPost /tmp/neomutt*    call FormatEmailRead()
augroup END
" }}}
