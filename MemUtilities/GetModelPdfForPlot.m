% GetModelPdfForPlot - allows PlotModelFit() to plot arbitrary pdfs.
%
% adds pdfForPlot to a model, a function that allows you to plot a pdf 
% with arbitrary requirements. For example, with the swap model, it will be
% appropriately 'bumpy', as though we averaged across all the displays.
% 
% It is used by PlotModelFit(), so for example you can do this:
%
%   newData = MemDataset(3);
%   newData.errors = newData.errors(:,1:30);
%   newData.distractors = newData.distractors(:,1:30);
%   model = SwapModel();
%   PlotModelFit(model, [.1 .5 20], newData);
%
%  and should see bumps where distractors were more common in the first 30
%  displays.

function model = GetModelPdfForPlot(model)
  
  % Check if we need extra information to call the pdf
  requiresSeparatePDFs = DoesModelRequireExtraInfo(model);
  
  % If the model doesn't require separate information to call the pdf, just
  % call it once for all the data points by pretending the values we want
  % to plot are the errors
  if ~requiresSeparatePDFs
    model.pdfForPlot = @(vals, data, varargin) model.pdf(struct('errors',vals), varargin{:});
    return;
  end
  
  % If the model does require separate information to call the pdf, call it
  % separately for each value we want to plot, and average across all the
  % pdf values for all of the datapoints 
  model.pdfForPlot = @NewPdfForPlot;
  function p = NewPdfForPlot(vals, data, varargin)
    sz = size(data.errors);
    for i=1:length(vals)
      data.errors = repmat(vals(i), sz);
      y(:,i) = model.pdf(data, varargin{:});
    end
    p = mean(y);
  end
end