require 'spec_helper'

RSpec.describe Jekyll::AttendeasePlugin::Helpers do
  context '#parameterize' do
    it 'converts a typical filter item into a predictable CSS-friendly class name' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('Super Hyper Advanced', '-')).to eq('super-hyper-advanced')
    end

    it 'converts a title to a snake-case style string' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize(' That quick brown fox? Jumps over the lazy dog...')).to eq('that_quick_brown_fox_jumps_over_the_lazy_dog')
    end

    it 'converts accented characters to an ASCII-equivalent' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('Pepé Le Pew')).to eq('pepe_le_pew')
    end

    it 'will not repeat the separator' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('What--the--hell?')).to eq('what_the_hell')
    end

    it 'will strip leading and trailing separators' do
      expect(Jekyll::AttendeasePlugin::Helpers.parameterize('-, What--the--hell? ::')).to eq('what_the_hell')
    end
  end
end
