requires 'Term::ANSIColor', '2.01';
requires 'Unicode::EastAsianWidth', '1.30';
requires 'perl', '5.008001';

on 'configure' => sub {
    requires 'Module::Build::Tiny';
};

on 'test' => sub {
    requires 'Test::More', '0.88';
};
