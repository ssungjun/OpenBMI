function [event] = read_yokogawa_event(filename, varargin)

% READ_YOKOGAWA_EVENT reads event information from continuous,
% epoched or averaged MEG data that has been generated by the Yokogawa
% MEG system and software and allows those events to be used in
% combination with FieldTrip.
%
% Use as
%   [event] = read_yokogawa_event(filename)
%
% See also READ_YOKOGAWA_HEADER, READ_YOKOGAWA_DATA

% Copyright (C) 2005, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: read_yokogawa_event.m 2617 2011-01-20 15:19:35Z jorhor $

if ~ft_hastoolbox('yokogawa')
    error('cannot determine whether Yokogawa toolbox is present');
end

% get the options
trigindx = keyval('trigindx', varargin); % default is based on chantype helper function

event   = [];
handles = definehandles;

% read the dataset header
hdr = read_yokogawa_header(filename);

if hdr.orig.acq_type==handles.AcqTypeEvokedRaw
  % read the trigger id from all trials
  fid   = fopen(filename, 'r');
  value = GetMeg160TriggerEventM(fid);
  fclose(fid);
  % use the standard FieldTrip header for trial events
  % make an event for each trial as defined in the header
  for i=1:hdr.nTrials
    event(end+1).type     = 'trial';
    event(end  ).sample   = (i-1)*hdr.nSamples + 1;
    event(end  ).offset   = -hdr.nSamplesPre;
    event(end  ).duration =  hdr.nSamples;

    if ~isempty(value)
      event(end  ).value    =  value(i);
    end
  end

elseif hdr.orig.acq_type==handles.AcqTypeEvokedAve
  % make an event for the average
  event(1).type     = 'average';
  event(1).sample   = 1;
  event(1).offset   = -hdr.nSamplesPre;
  event(1).duration =  hdr.nSamples;

elseif hdr.orig.acq_type==handles.AcqTypeContinuousRaw
  % read the trigger channel and detect the flanks
  if isempty(trigindx)
    trigindx = find(hdr.orig.channel_info(:,2)==handles.TriggerChannel);
  end
  event = read_trigger(filename, 'header', hdr, 'chanindx', trigindx, 'detectflank', 'both');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this defines some usefull constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = definehandles;
handles.output = [];
handles.sqd_load_flag = false;
handles.mri_load_flag = false;
handles.NullChannel         = 0;
handles.MagnetoMeter        = 1;
handles.AxialGradioMeter    = 2;
handles.PlannerGradioMeter  = 3;
handles.RefferenceChannelMark = hex2dec('0100');
handles.RefferenceMagnetoMeter       = bitor( handles.RefferenceChannelMark, handles.MagnetoMeter );
handles.RefferenceAxialGradioMeter   = bitor( handles.RefferenceChannelMark, handles.AxialGradioMeter );
handles.RefferencePlannerGradioMeter = bitor( handles.RefferenceChannelMark, handles.PlannerGradioMeter );
handles.TriggerChannel      = -1;
handles.EegChannel          = -2;
handles.EcgChannel          = -3;
handles.EtcChannel          = -4;
handles.NonMegChannelNameLength = 32;
handles.DefaultMagnetometerSize       = (4.0/1000.0);       % Square of 4.0mm in length
handles.DefaultAxialGradioMeterSize   = (15.5/1000.0);      % Circle of 15.5mm in diameter
handles.DefaultPlannerGradioMeterSize = (12.0/1000.0);      % Square of 12.0mm in length
handles.AcqTypeContinuousRaw = 1;
handles.AcqTypeEvokedAve     = 2;
handles.AcqTypeEvokedRaw     = 3;
handles.sqd = [];
handles.sqd.selected_start  = [];
handles.sqd.selected_end    = [];
handles.sqd.axialgradiometer_ch_no      = [];
handles.sqd.axialgradiometer_ch_info    = [];
handles.sqd.axialgradiometer_data       = [];
handles.sqd.plannergradiometer_ch_no    = [];
handles.sqd.plannergradiometer_ch_info  = [];
handles.sqd.plannergradiometer_data     = [];
handles.sqd.eegchannel_ch_no   = [];
handles.sqd.eegchannel_data    = [];
handles.sqd.nullchannel_ch_no   = [];
handles.sqd.nullchannel_data    = [];
handles.sqd.selected_time       = [];
handles.sqd.sample_rate         = [];
handles.sqd.sample_count        = [];
handles.sqd.pretrigger_length   = [];
handles.sqd.matching_info   = [];
handles.sqd.source_info     = [];
handles.sqd.mri_info        = [];
handles.mri                 = [];